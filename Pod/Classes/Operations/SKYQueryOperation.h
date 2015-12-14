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
#import "SKYQueryCursor.h"

@interface SKYQueryOperation : SKYDatabaseOperation

- (instancetype)initWithQuery:(SKYQuery *)query;
- (instancetype)initWithCursor:(SKYQueryCursor *)cursor;

+ (instancetype)operationWithQuery:(SKYQuery *)query;
+ (instancetype)operationWithCursor:(SKYQueryCursor *)cursor;

@property (nonatomic, copy) SKYQuery *query;
@property (nonatomic, copy) NSArray *results __deprecated;

/**
 Returns the nubmer of all matching records if the original query requested this info.
 */
@property (nonatomic, readonly) NSUInteger overallCount;

@property (nonatomic, copy) void (^perRecordCompletionBlock)(SKYRecord *record);
@property (nonatomic, copy) void (^queryRecordsCompletionBlock)
    (NSArray *fetchedRecords, SKYQueryCursor *cursor, NSError *operationError);

@end
