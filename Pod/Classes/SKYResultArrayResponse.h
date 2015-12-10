//
//  SKYResultArrayResponse.h
//  SkyKit
//
//  Copyright 2015 Oursky Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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
