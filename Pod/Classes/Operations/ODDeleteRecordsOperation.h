//
//  ODDeleteRecordsOperation.h
//  Pods
//
//  Created by Patrick Cheung on 1/3/15.
//
//

#import "ODDatabaseOperation.h"
#import "ODRecord.h"
#import "ODRecordID.h"

/**
 <ODDeleteRecordsOperation> is a subclass of <ODDatabaseOperation> that implements records deletion in Ourd. Use this operation
 to delete multiple existing records from the database.
 */
@interface ODDeleteRecordsOperation : ODDatabaseOperation

/**
 Instantiates an instance of <ODDeleteRecordsOperation> with a list of records to be deleted from database.
 
 @param records An array of records to be deleted from database.
 */
- (instancetype)initWithRecordIDsToDelete:(NSArray *)recordIDs;

/**
 Sets or returns an array of records to be from from database.
 */
@property (nonatomic, copy) NSArray *recordIDs;

/**
 Sets whether the operation should be treated as an atomic operation. An atomic operation saves all the
 modifications should there be no errors. If some of the <ODRecord>s are deleted successfully while some are not,
 the database will treat the delete as not happened at all.

 The default value of this property is NO.
 */
@property (nonatomic, assign) BOOL atomic;

/**
 Sets or returns a block to be called when progress information is available for deleting each record.
 */
@property (nonatomic, copy) void (^perRecordProgressBlock)(ODRecordID *recordID, double progress);

/**
 Sets or returns a block to be called when the delete operation for individual record is completed.
 If an error occurred during the deletion, the <NSError> will be specified.
 */
@property (nonatomic, copy) void (^perRecordCompletionBlock)(ODRecordID *deletedRecordID, NSError *error);

/**
 Sets or returns a block to be called when the entire operation completes. If the entire operation
 results in an error, the <NSError> will be specified.
 */
@property (nonatomic, copy) void (^deleteRecordsCompletionBlock)(NSArray *deletedRecordIDs, NSError *operationError);


@end
