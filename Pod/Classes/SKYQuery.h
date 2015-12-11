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

@interface SKYQuery : NSObject <NSSecureCoding>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithRecordType:(NSString *)recordType
                         predicate:(NSPredicate *)predicate NS_DESIGNATED_INITIALIZER;

+ (instancetype)queryWithRecordType:(NSString *)recordType predicate:(NSPredicate *)predicate;

@property (nonatomic, readonly, copy) NSString *recordType;
@property (nonatomic, readonly, copy) NSPredicate *predicate;
@property (nonatomic, copy) NSArray *sortDescriptors;

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
@property (strong, nonatomic) NSDictionary *transientIncludes;

@end
