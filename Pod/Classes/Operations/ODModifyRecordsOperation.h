//
//  ODModifyRecordsOperation.h
//  askq
//
//  Created by Kenji Pa on 22/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODDatabaseOperation.h"

typedef enum : NSInteger {
    ODRecordSaveIfServerRecordUnchanged = 0,
    ODRecordSaveChangedKeys = 1,
    ODRecordSaveAllKeys = 2,
} ODRecordSavePolicy;

/**
 <ODModifyRecordsOperation> is a subclass of <ODDatabaseOperation> that implements record saving to Ourd.
 Use this operation to save new record or modify existing record in the database.
 */
@interface ODModifyRecordsOperation : ODDatabaseOperation

/**
 Instantiates an instance of <OdModifyRecordsOperation> with a list of records to be saved to database.
 
 @param records An array of records to be saved to database.
 */
- (instancetype)initWithRecordsToSave:(NSArray *)records;

/**
 Creates and returns an instance of <OdModifyRecordsOperation> with a list of records to be saved to database.

 @param records An array of records to be saved to database.
 */
+ (instancetype)operationWithRecordsToSave:(NSArray *)records;

/**
 Sets or returns an array of records to be saved to database.
 */
@property (nonatomic, copy) NSArray *recordsToSave;

/**
 Sets whether the operation should be treated as an atomic operation. An atomic operation saves all the
 modifications should there be no errors. If some of the <ODRecord>s saves successfully while some are not,
 the database will treat the save as not happened at all.

 The default value of this property is NO.
 */
@property (nonatomic, assign) BOOL atomic;

/**
 Sets or returns a block to be called when progress information is available for saving each record.
 */
@property (nonatomic, copy) void (^perRecordProgressBlock)(ODRecord *record, double progress);

/**
 Sets or returns a block to be called when the save operation for individual record is completed.
 If an error occurred during the save, the <NSError> will be specified.
 */
@property (nonatomic, copy) void (^perRecordCompletionBlock)(ODRecord *record, NSError *error);

/**
 Sets or returns a block to be called when the entire operation completes. If the entire operation
 results in an error, the <NSError> will be specified.
 */
@property (nonatomic, copy) void (^modifyRecordsCompletionBlock)(NSArray *savedRecords, NSError *operationError);

@end
