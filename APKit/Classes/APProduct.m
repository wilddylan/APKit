//
//  APProduct.m
//  Pods
//
//  Created by Dylan on 2016/9/23.
//
//

#import "APProduct.h"

@implementation APProduct

-(instancetype)init {
	self = [self initWithName:nil elements:@[]];
	if( self ) {
		
	}
	return self;
}

-(instancetype)initWithName: (NSString *)name
									 elements: (NSArray *)elements {
	self = [super init];
	if( self ) {
		_name = [name copy];
		_elements = elements;
	}
	return self;
}

@end
