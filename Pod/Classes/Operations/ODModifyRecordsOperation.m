//
//  ODModifyRecordsOperation.m
//  askq
//
//  Created by Kenji Pa on 22/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODModifyRecordsOperation.h"
#import "ODRecordSerializer.h"
#import "ODRecordSerialization.h"
#import "ODDataSerialization.h"

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

- (NSArray *)processResultArray:(NSArray *)result
{
    NSMutableArray *savedRecords = [NSMutableArray array];
    [result enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSError *error = nil;
        ODRecord *record = nil;
        ODRecordID *recordID = [ODRecordID recordIDWithCanonicalString:obj[ODRecordSerializationRecordIDKey]];
        
        if (recordID) {
            record = [recordsByRecordID objectForKey:recordID];
            
            if (!record) {
                NSLog(@"A returned record ID is not requested.");
            }

            if ([obj[ODRecordSerializationRecordTypeKey] isEqualToString:@"record"]) {
            } else if ([obj[ODRecordSerializationRecordTypeKey] isEqualToString:@"error"]) {
                NSMutableDictionary *userInfo = [ODDataSerialization userInfoWithErrorDictionary:obj];
                userInfo[NSLocalizedDescriptionKey] = @"An error occurred while modifying record.";
                error = [NSError errorWithDomain:(NSString *)ODOperationErrorDomain
                                            code:0
                                        userInfo:userInfo];
            }
        } else {
            NSMutableDictionary *userInfo = [self errorUserInfoWithLocalizedDescription:@"Missing `_id` or not in correct format."
                                                                        errorDictionary:nil];
            error = [NSError errorWithDomain:(NSString *)ODOperationErrorDomain
                                        code:0
                                    userInfo:userInfo];
        }
        
        if ((record || error) && self.perRecordCompletionBlock) {
            self.perRecordCompletionBlock(record, error);
        }
        
        if (record && !error) {
            [savedRecords addObject:record];
        }
    }];
    
    return savedRecords;
}

- (void)updateCompletionBlock
{
    if (self.perRecordCompletionBlock || self.modifyRecordsCompletionBlock) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            NSArray *resultArray = nil;
            NSError *error = weakSelf.error;
            if (!error) {
                NSArray *responseArray = weakSelf.response[@"result"];
                if ([responseArray isKindOfClass:[NSArray class]]) {
                    resultArray = [weakSelf processResultArray:responseArray];
                } else {
                    NSDictionary *userInfo = [weakSelf errorUserInfoWithLocalizedDescription:@"Server returned malformed result."
                                                                             errorDictionary:nil];
                    error = [NSError errorWithDomain:(NSString *)ODOperationErrorDomain
                                                code:0
                                            userInfo:userInfo];
                }
            }
            
            if (weakSelf.modifyRecordsCompletionBlock) {
                weakSelf.modifyRecordsCompletionBlock(resultArray, error);
            }

        };
    }
}

@end
