//
//  SKYModifyRecordsOperation.m
//  askq
//
//  Created by Kenji Pa on 22/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYModifyRecordsOperation.h"
#import "SKYRecordSerializer.h"
#import "SKYRecordSerialization.h"
#import "SKYDataSerialization.h"

@implementation SKYModifyRecordsOperation {
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

+ (instancetype)operationWithRecordsToSave:(NSArray *)records
{
    return [[self alloc] initWithRecordsToSave:records];
}

- (void)prepareForRequest
{
    SKYRecordSerializer *serializer = [SKYRecordSerializer serializer];
    
    NSMutableArray *dictionariesToSave = [NSMutableArray array];
    recordsByRecordID = [NSMutableDictionary dictionary];
    [self.recordsToSave enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [dictionariesToSave addObject:[serializer dictionaryWithRecord:obj]];
        [recordsByRecordID setObject:obj forKey:[(SKYRecord *)obj recordID]];
    }];

    NSMutableDictionary *payload = [@{
                                      @"records": dictionariesToSave,
                                      @"database_id": self.database.databaseID,
                                      } mutableCopy];
    if (self.atomic) {
        payload[@"atomic"] = @YES;
    }

    self.request = [[SKYRequest alloc] initWithAction:@"record:save"
                                             payload:payload];
    self.request.accessToken = self.container.currentAccessToken;
}

- (void)setPerRecordCompletionBlock:(void (^)(SKYRecord *, NSError *))perRecordCompletionBlock
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
        SKYRecord *record = nil;
        SKYRecordID *recordID = [SKYRecordID recordIDWithCanonicalString:obj[SKYRecordSerializationRecordIDKey]];
        
        if (recordID) {
            record = [recordsByRecordID objectForKey:recordID];
            
            if (!record) {
                NSLog(@"A returned record ID is not requested.");
            }

            if ([obj[SKYRecordSerializationRecordTypeKey] isEqualToString:@"record"]) {
            } else if ([obj[SKYRecordSerializationRecordTypeKey] isEqualToString:@"error"]) {
                NSMutableDictionary *userInfo = [SKYDataSerialization userInfoWithErrorDictionary:obj];
                userInfo[NSLocalizedDescriptionKey] = @"An error occurred while modifying record.";
                error = [NSError errorWithDomain:(NSString *)SKYOperationErrorDomain
                                            code:0
                                        userInfo:userInfo];
            }
        } else {
            NSMutableDictionary *userInfo = [self errorUserInfoWithLocalizedDescription:@"Missing `_id` or not in correct format."
                                                                        errorDictionary:nil];
            error = [NSError errorWithDomain:(NSString *)SKYOperationErrorDomain
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
                    error = [NSError errorWithDomain:(NSString *)SKYOperationErrorDomain
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
