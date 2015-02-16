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

@interface ODModifyRecordsOperation : ODDatabaseOperation

- (instancetype)initWithRecordsToSave:(NSArray *)records
                    recordIDsToDelete:(NSArray *)recordIDs;

@property (nonatomic, copy) NSArray *recordsToSave;
@property (nonatomic, copy) NSArray *recordIDsToDelete;

@property (nonatomic, copy) void (^perRecordProgressBlock)(ODRecord *record, double progress);
@property (nonatomic, copy) void (^perRecordCompletionBlock)(ODRecord *record, NSError *error);
@property (nonatomic, copy) void (^modifyRecordsCompletionBlock)(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError);

@end
