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
#import "SKYRecordID.h"

/**
 <SKYDeleteRecordsOperation> is a subclass of <SKYDatabaseOperation> that implements records
 deletion in Ourd. Use this operation
 to delete multiple existing records from the database.
 */
@interface SKYDeleteRecordsOperation : SKYDatabaseOperation

/**
 Instantiates an instance of <SKYDeleteRecordsOperation> with a list of records to be deleted from
 database.

 @param records An array of records to be deleted from database.
 */
- (instancetype)initWithRecordIDsToDelete:(NSArray *)recordIDs;

/**
 Creates and returns an instance of <SKYDeleteRecordsOperation> with a list of records to be deleted
 from database.

 @param records An array of records to be deleted from database.
 */
+ (instancetype)operationWithRecordIDsToDelete:(NSArray *)recordIDs;

/**
 Sets or returns an array of records to be from from database.
 */
@property (nonatomic, copy) NSArray *recordIDs;

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
 Sets or returns a block to be called when progress information is available for deleting each
 record.
 */
@property (nonatomic, copy) void (^perRecordProgressBlock)(SKYRecordID *recordID, double progress);

/**
 Sets or returns a block to be called when the delete operation for individual record is completed.
 If an error occurred during the deletion, the <NSError> will be specified.
 */
@property (nonatomic, copy) void (^perRecordCompletionBlock)
    (SKYRecordID *deletedRecordID, NSError *error);

/**
 Sets or returns a block to be called when the entire operation completes. If the entire operation
 results in an error, the <NSError> will be specified.
 */
@property (nonatomic, copy) void (^deleteRecordsCompletionBlock)
    (NSArray *deletedRecordIDs, NSError *operationError);

@end
