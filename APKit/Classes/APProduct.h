//
//  APProduct.h
//  Pods
//
//  Created by Dylan on 2016/9/23.
//
//

#import <Foundation/Foundation.h>

@interface APProduct : NSObject

// Products/Purchases are organized by category
@property ( nonatomic, copy ) NSString *name;

// List of products/purchases
@property ( nonatomic, strong ) NSArray *elements;

// Create a model object
-(instancetype)initWithName: (NSString *)name
									 elements: (NSArray *)elements NS_DESIGNATED_INITIALIZER;

@end
