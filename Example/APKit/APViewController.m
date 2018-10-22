//
//  APViewController.m
//  APKit
//
//  Created by Dylan on 09/23/2016.
//  Copyright (c) 2016 Dylan. All rights reserved.
//

#import "APViewController.h"

#import <APKit/APKit.h>

@interface APViewController ()

@end

@implementation APViewController

- (instancetype)init {
  self = [super init];
  if ( self ) {

    /*
     * product request result notification, `APProductRequestNotification`
     */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleProductRequestNotification:)
                                                 name:APProductRequestNotification
                                               object:[APProductManager sharedInstance]];

    /*
     * purchase result notification, `APPurchaseNotification`
     */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePurchasesNotification:)
                                                 name:APPurchaseNotification
                                               object:[APStoreObserver sharedInstance]];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.

  /*
   * product identifier which you create in itunes-connect.
   */
  NSArray *productIdentifiers = @[
                                  @"1994101101",
                                  @"1994101102",
                                  @"1994101103"
                                  ];

  /*
   * get product shared instance
   */
  APProductManager *productManager = [APProductManager sharedInstance];
  [productManager
   fetchProductInformationForIds:productIdentifiers];
}

#pragma mark - Handle product request notification

-(void)handleProductRequestNotification: (NSNotification *)notification {

  APProductManager *productRequestNotification = (APProductManager*)notification.object;
  APProductRequestStatus result = (APProductRequestStatus)productRequestNotification.status;

  if (result == APProductRequestSuccess) {
    NSLog(@"VALID: %@", productRequestNotification.availableProducts);
    NSLog(@"INVALID: %@", productRequestNotification.invalidProductIds);

    NSLog(@"Auto buy 1994101101 After 3 seconds ...");

    dispatch_time_t sleepTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC));
    dispatch_after(sleepTime, dispatch_get_main_queue(), ^{
      NSArray *productArray = productRequestNotification.availableProducts;
      if ( productArray.count > 1 ) {
        SKProduct *product_1 = productArray.firstObject;
        SKProduct *product_2 = productArray.lastObject;

        /*
         * get purchase shared instance
         */
        APStoreObserver *storeObs = [APStoreObserver sharedInstance];

        [storeObs buy:product_1];
        [storeObs buy:product_2];
      }
    });
  }
}

#pragma mark - Handle purchase notification

-(void)handlePurchasesNotification: (NSNotification *)notification {
  APStoreObserver *purchasesNotification = (APStoreObserver *)notification.object;
  APPurchaseStatus status = (APPurchaseStatus)purchasesNotification.status;

  switch ( status ) {
// Purchase Notification
    case APPurchaseSucceeded: {
      NSLog(@"Purchase-Success: %@", purchasesNotification.productsPurchased);
      // !!! Verify receipts step.
      [self verifyReceipts];
      break;
    }
    case APPurchaseFailed: {
      NSLog(@"Purchase-Failed %@", purchasesNotification.errorMessage);
      break;
    }
    case APPurchaseCancelled: {
      NSLog(@"Purchase-Cancelled!");
      break;
    }
// Restore Notification
    case APRestoredSucceeded: {
      NSLog(@"Restored-Success: %@", purchasesNotification.productsRestored);
      break;
    }
    case APRestoredFailed: {
      NSLog(@"Restored-Failed %@", purchasesNotification.errorMessage);
      break;
    }
    case APRestoredCancelled: {
      NSLog(@"Restored-Cancelled!");
      break;
    }
// Download content

    default:
      break;
  }
}

- (void)verifyReceipts {
  NSURL *localReceiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
  NSData *data = [NSData dataWithContentsOfURL:localReceiptURL];
  NSString *receiptStr = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
#pragma unused(receiptStr)

  // Send to u'r server for validated!

  // Use this result!
#warning Server response is the real purchase order result, This is very import.
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
