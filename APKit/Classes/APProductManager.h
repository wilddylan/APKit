//
//  APProductManager.h
//  Pods
//
//  Created by Dylan on 2016/9/23.
//
//

#import <Foundation/Foundation.h>

// Provide notification about the product request
extern NSString * const APProductRequestNotification;

@interface APProductManager : NSObject
// Product request indicates
typedef NS_ENUM(NSInteger, APProductRequestStatus) {
    // Indicates that start request the product
    APProductRequestStart,
    // Returns valid products and invalid product identifiers
    APProductRequestSuccess,
    // Indicates that the product request fail with error
    APProductRequestFailure
};

// Provide the status of the product request
@property ( nonatomic ) APProductRequestStatus status;

// Keep track of all valid products. These products are available for sale in the App Store
@property ( nonatomic, strong ) NSMutableArray *availableProducts;

// Keep track of all invalid product identifiers
@property ( nonatomic, strong ) NSMutableArray *invalidProductIds;

// Keep track of all valid products (these products are available for sale in the App Store) and of all invalid product identifiers
@property ( nonatomic, strong ) NSMutableArray *productRequestResponse;

// Indicates the cause of the product request failure
@property ( nonatomic, copy ) NSString *errorMessage;

+ (APProductManager *)sharedInstance;

// Query the iTunes Connect about the given product identifiers
-(void)fetchProductInformationForIds: (NSArray *)productIds;

// Return the product's title matching a given product identifier
-(NSString *)titleMatchingProductIdentifier: (NSString *)identifier;

@end
