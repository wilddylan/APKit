//
//  APProductManager.m
//  Pods
//
//  Created by Dylan on 2016/9/23.
//
//

#import "APProductManager.h"
#import "APProduct.h"

#import <StoreKit/StoreKit.h>

NSString * const APProductRequestNotification = @"APProductRequestNotification";

@interface APProductManager () <SKRequestDelegate, SKProductsRequestDelegate>
@end

@implementation APProductManager

+ (APProductManager *)sharedInstance {
	static dispatch_once_t onceToken;
	static APProductManager *productManager;
	
	dispatch_once(&onceToken, ^{
		productManager = [[APProductManager alloc] init];
	});
	return productManager;
}

- (instancetype)init {
	self = [super init];
	if ( self ) {
		_availableProducts      = [[NSMutableArray alloc] initWithCapacity:0];
		_invalidProductIds      = [[NSMutableArray alloc] initWithCapacity:0];
		_productRequestResponse = [[NSMutableArray alloc] initWithCapacity:0];
	}
	return self;
}

#pragma mark - Request information

// Fetch information about your products from the iTunes Connect
- (void)fetchProductInformationForIds: (NSArray *)productIds {
	NSAssert(productIds, @"Need product ids.");
	if ( ![SKPaymentQueue canMakePayments] ) {
		self.status = APProductRequestFailure;
		self.errorMessage = @"Purchases are disabled on this device.";
		[[NSNotificationCenter defaultCenter] postNotificationName:APProductRequestNotification object:self];
		return ;
	}
	self.productRequestResponse = [[NSMutableArray alloc] initWithCapacity:0];
	// Create a product request object and initialize it with our product identifiers
	SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIds]];
	request.delegate = self;
	
	// Send the request to the iTunes Connect
	self.status = APProductRequestStart;
	[request start];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest: (SKProductsRequest *)request
		 didReceiveResponse: (SKProductsResponse *)response {
	APProduct *product = nil;
	
	// The products array contains products whose identifiers have been recognized by the App Store.
	// As such, they can be purchased. Create an "AVAILABLE_PRODUCTS" model object.
	if ( (response.products).count > 0 ) {
		product = [[APProduct alloc] initWithName:@"AVAILABLE_PRODUCTS" elements:response.products];
		// Add available product container to response array.
		[self.productRequestResponse addObject:product];
		// Add available product to availableProducts array.
		self.availableProducts = [NSMutableArray arrayWithArray:response.products];
	}
	
	// The invalidProductIdentifiers array contains all product identifiers not recognized by the App Store.
	// Create an "INVALID_PRODUCT IDS" model object.
	if ( (response.invalidProductIdentifiers).count > 0 ) {
		product = [[APProduct alloc] initWithName:@"INVALID_PRODUCT IDS" elements:response.invalidProductIdentifiers];
		// Add invalid product container to response array.
		[self.productRequestResponse addObject:product];
		// Add invalid product identifier to invalidProductIds array.
		self.invalidProductIds = [NSMutableArray arrayWithArray:response.invalidProductIdentifiers];
	}
	
	self.status = APProductRequestSuccess;
	[[NSNotificationCenter defaultCenter] postNotificationName:APProductRequestNotification object:self];
}

#pragma mark - SKRequestDelegate

- (void)request: (SKRequest *)request didFailWithError: (NSError *)error {
	self.status = APProductRequestFailure;
	self.errorMessage = [error.localizedDescription copy];
}

#pragma mark - Utils

- (NSString *)titleMatchingProductIdentifier: (NSString *)identifier {
	NSAssert(identifier, @"Need product identifier.");
	NSString *productTitle = nil;
	
	// Iterate through availableProducts to find the product whose productIdentifier
	// property matches identifier, return its localized title when found
	for ( SKProduct *product in self.availableProducts ) {
		if ( [product.productIdentifier isEqualToString:identifier] ) {
			productTitle = product.localizedTitle;
		}
	}
	return productTitle;
}

@end
