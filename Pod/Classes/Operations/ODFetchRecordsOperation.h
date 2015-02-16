//
//  ODFetchRecordsOperation.h
//  askq
//
//  Created by Kenji Pa on 21/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODDatabaseOperation.h"

@interface ODFetchRecordsOperation : ODDatabaseOperation

- (instancetype)initWithRecordIDs:(NSArray *)recordIDs;

@property(nonatomic, copy) NSArray *recordIDs;
@property(nonatomic, copy) NSArray *desiredKeys;

@property(nonatomic, copy) void (^perRecordProgressBlock)(ODRecordID *recordID, double progress);
@property(nonatomic, copy) void (^perRecordCompletionBlock)(ODRecord *record, ODRecordID *recordID, NSError *error);
@property(nonatomic, copy) void (^fetchRecordsCompletionBlock)(NSDictionary *recordsByRecordID, NSError *operationError);

@end
