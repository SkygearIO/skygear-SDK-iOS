//
//  SKYQueryOperation.h
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

#import "SKYDatabaseOperation.h"

#import "SKYQuery.h"
#import "SKYQueryInfo.h"

NS_ASSUME_NONNULL_BEGIN

/// Undocumented
@interface SKYQueryOperation : SKYDatabaseOperation

/// Undocumented
- (instancetype)initWithQuery:(SKYQuery *)query;

/// Undocumented
+ (instancetype)operationWithQuery:(SKYQuery *)query;

/// Undocumented
@property (nonatomic, copy) SKYQuery *query;
/// Undocumented
@property (nonatomic, copy) NSArray *_Nullable results __deprecated;

/**
 Returns the nubmer of all matching records if the original query requested this info.
 */
@property (nonatomic, readonly) NSUInteger overallCount __deprecated;

/// Undocumented
@property (nonatomic, copy) void (^_Nullable perRecordCompletionBlock)(SKYRecord *record)
    __deprecated;
/// Undocumented
@property (nonatomic, copy) void (^_Nullable queryRecordsCompletionBlock)
    (NSArray *_Nullable fetchedRecords, SKYQueryInfo *_Nullable cursor,
     NSError *_Nullable operationError);

@end

NS_ASSUME_NONNULL_END
