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
                
                [self completeTransaction:transaction forStatus:APPurchaseSucceeded];
                break;
            }
            case SKPaymentTransactionStateRestored: {
                // There are restored products
                self.purchasedID = transaction.payment.productIdentifier;
                [self.productsRestored addObject:transaction];
                
                [self completeTransaction:transaction forStatus:APRestoredSucceeded];
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
        NSLog(@"%@ was removed from the payment queue.", transaction.payment.productIdentifier);
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
    NSLog(@"All restorable transactions have been processed by the payment queue.");
}

#pragma mark - Complete transaction

// Notify the user about the purchase process. Start the download process if status is
// IAPDownloadStarted. Finish all transactions, otherwise.
-(void)completeTransaction: (SKPaymentTransaction *)transaction
                 forStatus: (APPurchaseStatus)status {
    self.status = status;
    //Do not send any notifications when the user cancels the purchase
    if (transaction.error.code == SKErrorPaymentCancelled) {
        self.status = APPurchaseCancelled;
    }
    // Remove the transaction from the queue for purchased and restored statuses
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [[NSNotificationCenter defaultCenter] postNotificationName:APPurchaseNotification object:self];
}

@end
