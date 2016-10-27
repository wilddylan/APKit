//
//  APStoreObserver.m
//  Pods
//
//  Created by Dylan on 2016/9/23.
//
//

#import "APStoreObserver.h"

NSString * const APPurchaseNotification = @"APPurchaseNotification";

@implementation APStoreObserver

+ (APStoreObserver *)sharedInstance {
	static dispatch_once_t onceToken;
	static APStoreObserver *storeObserver;
	
	dispatch_once(&onceToken, ^{
		storeObserver = [[APStoreObserver alloc] init];
	});
	return storeObserver;
}

- (instancetype)init {
	self = [super init];
	if ( self ) {
		_productsPurchased  = [[NSMutableArray alloc] initWithCapacity:0];
		_productsRestored   = [[NSMutableArray alloc] initWithCapacity:0];
		_logEnabled = YES;
	}
	return self;
}

#pragma mark - Make purchase

- (void)buy: (SKProduct *)product {
	SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
	// Add to default payment queue.
	[[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - Has purchased products

// Returns whether there are purchased products
- (BOOL)hasPurchasedProducts {
	return (self.productsPurchased.count > 0);
}

#pragma mark - Has restored products

// Returns whether there are restored purchases
- (BOOL)hasRestoredProducts {
	return (self.productsRestored.count > 0);
}

#pragma mark - Make Restore

- (void)restore {
	self.productsRestored = [[NSMutableArray alloc] initWithCapacity:0];
	// Restore completed stores
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - SKPaymentTransactionObserver

// Called when there are trasactions in the payment queue
- (void)paymentQueue: (SKPaymentQueue *)queue
 updatedTransactions: (NSArray<SKPaymentTransaction *> *)transactions {
	for ( SKPaymentTransaction *transaction  in transactions) {
		switch (transaction.transactionState ) {
			case SKPaymentTransactionStatePurchasing:
				// In purchasing
				self.status = APPurchasing;
				break;
			case SKPaymentTransactionStateDeferred:
				// Is deferred. Do not block your UI. Allow the user to continue using your app.
				self.status = APPurchaseDeferred;
				break;
			case SKPaymentTransactionStatePurchased: {
				// The purchase was successful
				self.purchasedID = transaction.payment.productIdentifier;
				[self.productsPurchased addObject:transaction];
				// Check is have host content or not.
				if(transaction.downloads && transaction.downloads.count > 0) {
					[self completeTransaction:transaction forStatus:APDownloadStarted];
				} else {
					[self completeTransaction:transaction forStatus:APPurchaseSucceeded];
				}
				break;
			}
			case SKPaymentTransactionStateRestored: {
				// There are restored products
				self.purchasedID = transaction.payment.productIdentifier;
				[self.productsRestored addObject:transaction];
				
				if(transaction.downloads && transaction.downloads.count > 0) {
					[self completeTransaction:transaction forStatus:APDownloadStarted];
				} else {
					[self completeTransaction:transaction forStatus:APRestoredSucceeded];
				}
				break;
			}
			case SKPaymentTransactionStateFailed: {
				// The transaction failed
				self.errorMessage = [NSString stringWithFormat:@"Purchase of %@ failed.",transaction.payment.productIdentifier];
				[self completeTransaction:transaction forStatus:APPurchaseFailed];
				break;
			}
			default:
				break;
		}
	}
}

// Logs all transactions that have been removed from the payment queue
- (void)paymentQueue: (SKPaymentQueue *)queue
 removedTransactions: (NSArray *)transactions {
	for(SKPaymentTransaction * transaction in transactions) {
		if ( _logEnabled ) {
			NSLog(@"%@ was removed from the payment queue.", transaction.payment.productIdentifier);
		}
	}
}

// Called when an error occur while restoring purchases. Notify the user about the error.
- (void)paymentQueue: (SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError: (NSError *)error {
	if (error.code != SKErrorPaymentCancelled) {
		self.status = APRestoredFailed;
		self.errorMessage = error.localizedDescription;
	} else {
		self.status = APRestoredCancelled;
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:APPurchaseNotification object:self];
}

// Called when all restorable transactions have been processed by the payment queue
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
	if ( _logEnabled ) {
		NSLog(@"All restorable transactions have been processed by the payment queue.");
	}
}

// Called when the payment queue has downloaded content
- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads {
	for (SKDownload* download in downloads) {
		switch (download.downloadState) {
				// The content is being downloaded. Let's provide a download progress to the user
			case SKDownloadStateActive: {
				self.status = APDownloadInProgress;
				self.purchasedID = download.transaction.payment.productIdentifier;
				self.downloadProgress = download.progress*100;
				[[NSNotificationCenter defaultCenter] postNotificationName:APPurchaseNotification object:self];
				break;
			}
			case SKDownloadStateCancelled: {
				// StoreKit saves your downloaded content in the Caches directory. Let's remove it
				// before finishing the transaction.
				[[NSFileManager defaultManager] removeItemAtURL:download.contentURL error:nil];
				[self finishDownloadTransaction:download.transaction];
				break;
			}
			case SKDownloadStateFailed: {
				// If a download fails, remove it from the Caches, then finish the transaction.
				// It is recommended to retry downloading the content in this case.
				[[NSFileManager defaultManager] removeItemAtURL:download.contentURL error:nil];
				[self finishDownloadTransaction:download.transaction];
				break;
			}
			case SKDownloadStatePaused: {
				if ( _logEnabled ) {
					NSLog(@"Download was paused");
				}
				self.status = APDownloadPaused;
				[[NSNotificationCenter defaultCenter] postNotificationName:APPurchaseNotification object:self];
				break;
			}
			case SKDownloadStateFinished: {
				// Download is complete. StoreKit saves the downloaded content in the Caches directory.
				if ( _logEnabled ) {
					NSLog(@"Location of downloaded file %@",download.contentURL);
				}
				[self finishDownloadTransaction:download.transaction];
				break;
			}
			case SKDownloadStateWaiting: {
				if ( _logEnabled ) {
					NSLog(@"Download Waiting");
				}
				[[SKPaymentQueue defaultQueue] startDownloads:@[download]];
				break;
			}
			default:
				break;
		}
	}
}

#pragma mark - Complete transaction

// Notify the user about the purchase process. Start the download process if status is
// IAPDownloadStarted. Finish all transactions, otherwise.
-(void)completeTransaction: (SKPaymentTransaction *)transaction
								 forStatus: (APPurchaseStatus)status {
	self.status = status;
	// In Apple's Demo, they said: `Do not notify the user when purchase cancelled.`
	if (transaction.error.code == SKErrorPaymentCancelled) {
		self.status = APPurchaseCancelled;
	}
	// Notify the user
	[[NSNotificationCenter defaultCenter] postNotificationName:APPurchaseNotification object:self];
	
	if (status == APDownloadStarted) {
		// The purchased product is a hosted one, let's download its content
		[[SKPaymentQueue defaultQueue] startDownloads:transaction.downloads];
	} else {
		// Remove the transaction from the queue for purchased and restored statuses
		[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
	}
}

#pragma mark - Handle download transaction

- (void)finishDownloadTransaction:(SKPaymentTransaction*)transaction {
	//allAssetsDownloaded indicates whether all content associated with the transaction were downloaded.
	BOOL allAssetsDownloaded = YES;
	
	for (SKDownload* download in transaction.downloads) {
		if (download.downloadState != SKDownloadStateCancelled &&
				download.downloadState != SKDownloadStateFailed &&
				download.downloadState != SKDownloadStateFinished ) {
			//Let's break. We found an ongoing download. Therefore, there are still pending downloads.
			allAssetsDownloaded = NO;
			break;
		}
	}
	
	// Finish the transaction and post a APDownloadSucceeded notification if all downloads are complete
	if (allAssetsDownloaded) {
		self.status = APDownloadSucceeded;
	} else {
		self.status = APDownloadFailed;
	}
	
	// Notify the user download state.
	[[NSNotificationCenter defaultCenter] postNotificationName:APPurchaseNotification object:self];
	
	if ([self.productsRestored containsObject:transaction]) {
		// Restored succeed but download failure or succeed.
		self.status = APRestoredSucceeded;
	}
	if ([self.productsPurchased containsObject:transaction]) {
		// Payed succeed but download failure or succeed.
		self.status = APPurchaseSucceeded;
	}
	
	// Before do it, we see what apple say:
	// A download is complete if its state is SKDownloadStateCancelled, SKDownloadStateFailed, or SKDownloadStateFinished
	// and pending, otherwise. We finish a transaction if and only if all its associated downloads are complete.
	// For the SKDownloadStateFailed case, it is recommended to try downloading the content again before finishing the transaction.
	
	// They said `if and only if all its associated downloads are complete, SKDownloadStateFailed, it is recommended to try downloading the content again before finishing the transaction.`, but i think, should finish it! Control the retry and retry timeout should not in `APKit`, developer who use this framework should
	// check if or not have download contents and download state when receive the purchase or restore notification, APDownloadState in `APKit` only for help knowns the first time
	// content downloads.
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
	[[NSNotificationCenter defaultCenter] postNotificationName:APPurchaseNotification object:self];
}

@end
