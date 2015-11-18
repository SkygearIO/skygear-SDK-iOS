//
//  SKYOperation_Private.h
//  Pods
//
//  Created by Kwok-kuen Cheung on 18/11/2015.
//
//

#import "SKYOperation.h"

@interface SKYOperation ()

@property (nonatomic, readonly) NSDictionary *response __deprecated;
@property (nonatomic, readonly) NSError *error __deprecated;
@property (nonatomic, readonly) NSError *lastError;

@end