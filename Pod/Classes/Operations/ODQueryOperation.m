//
//  ODQueryOperation.m
//  askq
//
//  Created by Kenji Pa on 21/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODQueryOperation.h"
#import "ODRecordDeserializer.h"
#import "ODFollowQuery.h"
#import "ODQuerySerializer.h"

@interface ODQueryOperation()

@property ODQueryCursor *cursor;

@end

@implementation ODQueryOperation

- (instancetype)initWithQuery:(ODQuery *)query {
    self = [super init];
    if (self) {
        _query = query;
    }
    return self;
}

- (instancetype)initWithCursor:(ODQueryCursor *)cursor {
    self = [super init];
    if (self) {
        _cursor = cursor;
    }
    return self;
}

- (void)prepareForRequest
{
    ODQuerySerializer *serializer = [ODQuerySerializer serializer];
    NSMutableDictionary *payload = [@{
                                      @"database_id": self.database.databaseID,
                                      @"record_type": self.query.recordType,
                                      @"predicate": [serializer serializeWithPredicate:self.query.predicate],
                                      } mutableCopy];
    if ([self.query.sortDescriptors count] > 0) {
        payload[@"sort"] = [serializer serializeWithSortDescriptors:self.query.sortDescriptors];
    }
    self.request = [[ODRequest alloc] initWithAction:@"record:query"
                                             payload:payload];
    self.request.accessToken = self.container.currentAccessToken;
}

- (void)setPerRecordCompletionBlock:(void (^)(ODRecord *))perRecordCompletionBlock
{
    [self willChangeValueForKey:@"perRecordCompletionBlock"];
    _perRecordCompletionBlock = perRecordCompletionBlock;
    [self updateCompletionBlock];
    [self didChangeValueForKey:@"perRecordCompletionBlock"];
}

- (void)setQueryRecordsCompletionBlock:(void (^)(NSArray *, ODQueryCursor *, NSError *))queryRecordsCompletionBlock
{
    [self willChangeValueForKey:@"queryRecordsCompletionBlock"];
    _queryRecordsCompletionBlock = queryRecordsCompletionBlock;
    [self updateCompletionBlock];
    [self didChangeValueForKey:@"queryRecordsCompletionBlock"];
}

- (void)processResultArray:(NSArray *)result
{
    NSMutableArray *fetchedRecords = [NSMutableArray array];
    
    [result enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        if ([obj[@"_type"] hasPrefix:@"_"]) {
            // TODO: Call perRecordCompletionBlock with NSError
        } else {
            ODRecordDeserializer *deserializer = [ODRecordDeserializer deserializer];
            ODRecord *record = [deserializer recordWithDictionary:obj];
            [fetchedRecords addObject:record];
            if (self.perRecordCompletionBlock) {
                self.perRecordCompletionBlock(record);
            }
        }
    }];
    
    if (self.queryRecordsCompletionBlock) {
        self.queryRecordsCompletionBlock(fetchedRecords, nil, nil);
    }
}

- (void)updateCompletionBlock
{
    if (self.perRecordCompletionBlock || self.queryRecordsCompletionBlock) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            if (weakSelf.error) {
                if (weakSelf.queryRecordsCompletionBlock) {
                    weakSelf.queryRecordsCompletionBlock(nil, nil, weakSelf.error);
                }
            } else {
                [weakSelf processResultArray:weakSelf.response[@"result"]];
            }
        };
    }
}

@end
