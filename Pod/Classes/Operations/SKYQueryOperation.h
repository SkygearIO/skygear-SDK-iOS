//
//  SKYQueryOperation.h
//  askq
//
//  Created by Kenji Pa on 21/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
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

@property(nonatomic, copy) void (^perRecordCompletionBlock)(SKYRecord *record);
@property(nonatomic, copy) void (^queryRecordsCompletionBlock)(NSArray *fetchedRecords, SKYQueryCursor *cursor, NSError *operationError);

@end
