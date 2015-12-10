//
//  SKYOperation_Private.h
//  Pods
//
//  Created by Kwok-kuen Cheung on 18/11/2015.
//
//

#import "SKYOperation.h"

@interface SKYOperation ()

@property (nonatomic, readonly) NSDictionary *response;
@property (nonatomic, readonly) NSError *error;
@property (nonatomic, readonly) NSError *lastError;

@end