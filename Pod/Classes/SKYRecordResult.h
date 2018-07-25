//
//  SKYRecordResult.h
//  SKYKit
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
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 SKYRecordResult represents a sucessful result or an error.
 */
@interface SKYRecordResult <__covariant T> : NSObject

/**
 Gets the result.
 */
@property (nonatomic, readonly, nullable) T value;

/**
 Gets the error.
 */
@property (nonatomic, readonly, nullable) NSError *error;

- (instancetype)init NS_UNAVAILABLE;

/**
 Instantiate a SKYRecordResult with a result value.
 */
- (instancetype)initWithValue:(T)value;

/**
 Instantiate a SKYRecordResult with an error.
 */
- (instancetype)initWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
