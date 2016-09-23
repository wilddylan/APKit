//
//  APStoreObserver.h
//  Pods
//
//  Created by Dylan on 2016/9/23.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

// Provide notification about the purchase
extern NSString * const APPurchaseNotification;

@interface APStoreObserver : NSObject <SKPaymentTransactionObserver>

typedef NS_ENUM(NSInteger, APPurchaseStatus) {
    // Indicates that the purchase was in processing
    APPurchasing,
    // Indicates that the purchase was deferred
    APPurchaseDeferred,
    // Indicates that the purchase was cancelled
    APPurchaseCancelled,
    // Indicates that the purchase was unsuccessful
    APPurchaseFailed,
    // Indicates that the purchase was successful
    APPurchaseSucceeded,
    // Indicates that restoring products was cancelled
    APRestoredCancelled,
    // Indicates that restoring products was unsuccessful
    APRestoredFailed,
    // Indicates that restoring products was successful
    APRestoredSucceeded,
};

@property ( nonatomic ) APPurchaseStatus status;

// Keep track of all purchases
@property ( nonatomic, strong ) NSMutableArray *productsPurchased;

// Keep track of all restored purchases
@property ( nonatomic, strong ) NSMutableArray *productsRestored;

// Keep track of the purchased/restored product's identifier
@property (nonatomic, copy) NSString *purchasedID;

// Indicates the cause of the purchased/restored product failure
@property ( nonatomic, copy ) NSString *errorMessage;

-(BOOL)hasPurchasedProducts;
-(BOOL)hasRestoredProducts;

+ (APStoreObserver *)sharedInstance;

// Implement the purchase of a product
-(void)buy: (SKProduct *)product;

// Implement the restoration of previously completed purchases
-(void)restore;

@end
