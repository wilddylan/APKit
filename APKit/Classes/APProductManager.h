//
//  APProductManager.h
//  Pods
//
//  Created by Dylan on 2016/9/23.
//
//

#import <Foundation/Foundation.h>

// Provide notification about the product request
// 商品请求通知
extern NSString * const APProductRequestNotification;

@interface APProductManager : NSObject
// Product request indicates
// 商品请求的状态，开始-成功-失败
typedef NS_ENUM(NSInteger, APProductRequestStatus) {
	// Indicates that start request the product
	APProductRequestStart,
	// Returns valid products and invalid product identifiers
	APProductRequestSuccess,
	// Indicates that the product request fail with error
	APProductRequestFailure
};

// Provide the status of the product request
// 商品请求状态
@property ( nonatomic ) APProductRequestStatus status;

// Keep track of all valid products. These products are available for sale in the App Store
// 可以使用的商品
@property ( nonatomic, strong ) NSMutableArray *availableProducts;

// Keep track of all invalid product identifiers
// 不可以使用的商品
@property ( nonatomic, strong ) NSMutableArray *invalidProductIds;

// Keep track of all valid products (these products are available for sale in the App Store) and of all invalid product identifiers
// 所有的商品
@property ( nonatomic, strong ) NSMutableArray *productRequestResponse;

// Indicates the cause of the product request failure
// 错误信息，当请求失败的时候从这里读取
@property ( nonatomic, copy ) NSString *errorMessage;

+ (APProductManager *)sharedInstance;

// Query the iTunes Connect about the given product identifiers
// 请求这些商品Id，请求成功后，在可使用的商品数组或者不可使用的商品数组种
-(void)fetchProductInformationForIds: (NSArray *)productIds;

// Return the product's title matching a given product identifier
// 通过商品Id获得商品标题
-(NSString *)titleMatchingProductIdentifier: (NSString *)identifier;

@end
