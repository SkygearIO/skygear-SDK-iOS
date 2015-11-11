//
//  SKYResultArrayResponse.h
//  Pods
//
//  Created by atwork on 15/8/15.
//
//

#import <Foundation/Foundation.h>
#import "SKYResponse.h"

/**
 <SKYResultArrayResponse> implements a common processing pattern for processing response dictionary.

 The response dictionary is expected to contain an array specified with the key "result". Each
 item in the array is a dictionary for individual item. The dictionary must have the "_id" key which
 value will be used as the result key.
 */
@interface SKYResultArrayResponse : SKYResponse

/**
 Returns number of results.
 */
@property (nonatomic, readonly) NSUInteger count;

/**
 Enumerate result dictionary in result array.
 */
- (void)enumerateResultsUsingBlock:(void (^)(NSString *resultKey, NSDictionary *result,
                                             NSError *error, NSUInteger idx, BOOL *stop))block;

@end
