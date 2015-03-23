//
//  ODFetchRecordsOperation.m
//  askq
//
//  Created by Kenji Pa on 21/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODFetchRecordsOperation.h"

#import "ODUser.h"
#import "ODUserRecordID.h"
#import "ODRecordDeserializer.h"

@implementation ODFetchRecordsOperation

- (instancetype)initWithRecordIDs:(NSArray *)recordIDs {
    self = [super init];
    if (self) {
        _recordIDs = recordIDs;
    }
    return self;
}

- (void)prepareForRequest
{
    NSMutableArray *stringIDs = [NSMutableArray array];
    [self.recordIDs enumerateObjectsUsingBlock:^(ODRecordID *obj, NSUInteger idx, BOOL *stop) {
        [stringIDs addObject:[obj canonicalString]];
    }];
    NSMutableDictionary *payload = [@{
                                     @"ids": stringIDs,
                                     @"database_id": self.database.databaseID,
                                     } mutableCopy];
    if ([self.desiredKeys count]) {
        payload[@"desired_keys"] = self.desiredKeys;
    }
    self.request = [[ODRequest alloc] initWithAction:@"record:fetch"
                                             payload:payload];
    self.request.accessToken = self.container.currentAccessToken;
}

- (void)setPerRecordCompletionBlock:(void (^)(ODRecord *, ODRecordID *, NSError *))perRecordCompletionBlock
{
    [self willChangeValueForKey:@"perRecordCompletionBlock"];
    _perRecordCompletionBlock = perRecordCompletionBlock;
    [self updateCompletionBlock];
    [self didChangeValueForKey:@"perRecordCompletionBlock"];
}

- (void)setFetchRecordsCompletionBlock:(void (^)(NSDictionary *, NSError *))fetchRecordsCompletionBlock
{
    [self willChangeValueForKey:@"fetchRecordsCompletionBlock"];
    _fetchRecordsCompletionBlock = fetchRecordsCompletionBlock;
    [self updateCompletionBlock];
    [self didChangeValueForKey:@"fetchRecordsCompletionBlock"];
}

- (void)processResultArray:(NSArray *)result
{
    NSMutableDictionary *recordsByRecordID = [NSMutableDictionary dictionary];
    
    [result enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        if ([obj[@"_type"] hasPrefix:@"_"]) {
            // TODO: Call perRecordCompletionBlock with NSError
        } else {
            ODRecordDeserializer *deserializer = [ODRecordDeserializer deserializer];
            ODRecord *record = [deserializer recordWithDictionary:obj];
            [recordsByRecordID setObject:record forKey:record.recordID];
            if (self.perRecordCompletionBlock) {
                self.perRecordCompletionBlock(record, record.recordID, nil);
            }
        }
    }];
    
    if (self.fetchRecordsCompletionBlock) {
        self.fetchRecordsCompletionBlock(recordsByRecordID, nil);
    }
}

- (void)updateCompletionBlock
{
    if (self.perRecordCompletionBlock || self.fetchRecordsCompletionBlock) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            if (weakSelf.error) {
                if (weakSelf.fetchRecordsCompletionBlock) {
                    weakSelf.fetchRecordsCompletionBlock(nil, weakSelf.error);
                }
            } else {
                [weakSelf processResultArray:weakSelf.response[@"result"]];
            }
        };
    }
}

@end
