//
//  SKYDeleteRecordsOperation.h
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
#import "SKYRecord.h"
#import "SKYRecordResult.h"

NS_ASSUME_NONNULL_BEGIN

/**
 <SKYDeleteRecordsOperation> is a subclass of <SKYDatabaseOperation> that implements records
 deletion in Skygear. Use this operation
 to delete multiple existing records from the database.
 */
@interface SKYDeleteRecordsOperation : SKYDatabaseOperation

/**
 Creates an operation to delete records with the specified record type and record IDs.

 The number of record types should match the number of record IDs, with each element correspond
 to each other.

 @param recordTypes array of record type to delete
 @param recordIDs array of record IDs to delete
 @return instance of SKYDeleteRecordsOperation
 */
- (instancetype)initWithRecordTypes:(NSArray<NSString *> *)recordTypes
                          recordIDs:(NSArray<NSString *> *)recordIDs NS_DESIGNATED_INITIALIZER;

/**
 Creates an operation to delete records with the specified records.

 @param records array of records to delete
 @return instance of SKYDeleteRecordsOperation
 */
- (instancetype)initWithRecords:(NSArray<SKYRecord *> *)records;

/**
 Creates an operation to delete records with the specified record type and record IDs.

 @param recordType record type to delete
 @param recordIDs array of record IDs to delete
 @return instance of SKYDeleteRecordsOperation
 */
- (instancetype)initWithRecordType:(NSString *)recordType
                         recordIDs:(NSArray<NSString *> *)recordIDs;

/**
 This method is deprecated.
 */
- (instancetype)initWithRecordIDsToDelete:(NSArray<SKYRecordID *> *)recordIDs
    __attribute__((deprecated));

/**
 Creates an operation to delete records with the specified records.

 @param records array of records to delete
 @return instance of SKYDeleteRecordsOperation
 */
+ (instancetype)operationWithRecords:(NSArray<SKYRecord *> *)records;

/**
 Creates an operation to delete records with the specified record type and record IDs.

 @param recordType record type to delete
 @param recordIDs array of record IDs to delete
 @return instance of SKYDeleteRecordsOperation
 */
+ (instancetype)operationWithRecordType:(NSString *)recordType
                              recordIDs:(NSArray<NSString *> *)recordIDs;

/**
 This method is deprecated.
 */
+ (instancetype)operationWithRecordIDsToDelete:(NSArray<SKYRecordID *> *)recordIDs
    __attribute__((deprecated));

/**
 Sets whether the operation should be treated as an atomic operation. An atomic operation saves all
 the
 modifications should there be no errors. If some of the <SKYRecord>s are deleted successfully while
 some are not,
 the database will treat the delete as not happened at all.

 The default value of this property is NO.
 */
@property (nonatomic, assign) BOOL atomic;

/**
 Sets or returns a block to be called when the entire operation completes. If the entire operation
 results in an error, the <NSError> will be specified.
 */
@property (nonatomic, copy) void (^_Nullable deleteRecordsCompletionBlock)
    (NSArray<SKYRecordResult<SKYRecord *> *> *_Nullable results, NSError *_Nullable operationError);

@end

NS_ASSUME_NONNULL_END
