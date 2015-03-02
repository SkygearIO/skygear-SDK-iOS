//
//  ODQueryOperation.h
//  askq
//
//  Created by Kenji Pa on 21/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODDatabaseOperation.h"

#import "ODQuery.h"
#import "ODQueryCursor.h"
#import "ODRecordZoneID.h"

@interface ODQueryOperation : ODDatabaseOperation

- (instancetype)initWithQuery:(ODQuery *)query;
- (instancetype)initWithCursor:(ODQueryCursor *)cursor;

@property (nonatomic, copy) ODQuery *query;
@property (nonatomic, copy) ODRecordZoneID *zoneID;
@property (nonatomic, copy) NSArray *results __deprecated;

@property(nonatomic, copy) void (^perRecordCompletionBlock)(ODRecord *record);
@property(nonatomic, copy) void (^queryRecordsCompletionBlock)(NSArray *fetchedRecords, ODQueryCursor *cursor, NSError *operationError);

@end
