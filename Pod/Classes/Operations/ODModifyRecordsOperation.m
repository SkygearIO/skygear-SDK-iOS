//
//  ODModifyRecordsOperation.m
//  askq
//
//  Created by Kenji Pa on 22/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODModifyRecordsOperation.h"
#import "ODRecordSerializer.h"

@implementation ODModifyRecordsOperation {
    NSMutableDictionary *recordsByRecordID;
}

- (instancetype)initWithRecordsToSave:(NSArray *)records
{
    self = [super init];
    if (self) {
        self.recordsToSave = records;
    }
    return self;
}

- (void)prepareForRequest
{
    ODRecordSerializer *serializer = [ODRecordSerializer serializer];
    
    NSMutableArray *dictionariesToSave = [NSMutableArray array];
    recordsByRecordID = [NSMutableDictionary dictionary];
    [self.recordsToSave enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [dictionariesToSave addObject:[serializer dictionaryWithRecord:obj]];
        [recordsByRecordID setObject:obj forKey:[(ODRecord *)obj recordID]];
    }];
    self.request = [[ODRequest alloc] initWithAction:@"record:save"
                                             payload:@{@"records": dictionariesToSave,
                                                       @"database_id": self.database.databaseID}];
    self.request.accessToken = self.container.currentAccessToken;
}

- (void)setPerRecordCompletionBlock:(void (^)(ODRecord *, NSError *))perRecordCompletionBlock
{
    [self willChangeValueForKey:@"perRecordCompletionBlock"];
    _perRecordCompletionBlock = [perRecordCompletionBlock copy];
    [self updateCompletionBlock];
    [self didChangeValueForKey:@"perRecordCompletionBlock"];
}

- (void)setModifyRecordsCompletionBlock:(void (^)(NSArray *, NSError *))modifyRecordsCompletionBlock
{
    [self willChangeValueForKey:@"modifyRecordsCompletionBlock"];
    _modifyRecordsCompletionBlock = [modifyRecordsCompletionBlock copy];
    [self updateCompletionBlock];
    [self didChangeValueForKey:@"modifyRecordsCompletionBlock"];
}

- (void)processResultArray:(NSArray *)result
{
    NSMutableArray *savedRecords = [NSMutableArray array];
    [result enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        if ([obj[@"_type"] hasPrefix:@"_"]) {
            // TODO: Call perRecordCompletionBlock with NSError
        } else {
            ODRecordID *recordID = [[ODRecordID alloc] initWithRecordType:obj[@"_type"] name:obj[@"_id"]];
            ODRecord *record = [recordsByRecordID objectForKey:recordID];
            if (self.perRecordCompletionBlock) {
                self.perRecordCompletionBlock(record, nil);
            }
            [savedRecords addObject:record];
        }
    }];
    
    if (self.modifyRecordsCompletionBlock) {
        self.modifyRecordsCompletionBlock(savedRecords, nil);
    }
}

- (void)updateCompletionBlock
{
    if (self.perRecordCompletionBlock || self.modifyRecordsCompletionBlock) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            if (weakSelf.error) {
                if (weakSelf.modifyRecordsCompletionBlock) {
                    weakSelf.modifyRecordsCompletionBlock(nil, weakSelf.error);
                }
            } else {
                [weakSelf processResultArray:weakSelf.response[@"result"]];
            }
        };
    }
}

@end
