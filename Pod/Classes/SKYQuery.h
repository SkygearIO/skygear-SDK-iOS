//
//  SKYQuery.h
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

/// Undocumented
@interface SKYQuery : NSObject <NSSecureCoding>

/// Undocumented
- (instancetype)init NS_UNAVAILABLE;
/// Undocumented
- (instancetype)initWithRecordType:(NSString *)recordType
                         predicate:(NSPredicate *_Nullable)predicate NS_DESIGNATED_INITIALIZER;

/// Undocumented
+ (instancetype)queryWithRecordType:(NSString *)recordType
                          predicate:(NSPredicate *_Nullable)predicate;

/// Undocumented
@property (nonatomic, readonly, copy) NSString *recordType;
/// Undocumented
@property (nonatomic, readonly, copy) NSPredicate *_Nullable predicate;
/// Undocumented
@property (nonatomic, copy) NSArray *_Nullable sortDescriptors;

/**
 Gets or sets the number of records after which records will be returned.

 Default is zero, meaning that the results contain record from the beginning of the result set.
 */
@property (nonatomic, readwrite) NSInteger offset;

/**
 Gets or sets the maximum number of records to be returned from the query.

 Default is zero, meaning that there is no limit.
 */
@property (nonatomic, readwrite) NSInteger limit;

/**
 Gets or sets whether to return the number of all matching records.
 */
@property (nonatomic, readwrite) BOOL overallCount;

/**
 An NSDictionary of expression to be evaluated on the server side and returned as transient
 dictionary in SKYRecord.
 */
@property (strong, nonatomic) NSDictionary *_Nullable transientIncludes;

@end

NS_ASSUME_NONNULL_END
