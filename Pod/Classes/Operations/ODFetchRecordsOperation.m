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
#import "ODRecordSerialization.h"
#import "ODDataSerialization.h"

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

- (NSDictionary *)processResultArray:(NSArray *)result
{
    NSMutableDictionary *recordsByRecordID = [NSMutableDictionary dictionary];
    
    [result enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSError *error = nil;
        ODRecord *record = nil;
        ODRecordID *recordID = [ODRecordID recordIDWithCanonicalString:obj[ODRecordSerializationRecordIDKey]];
        
        if (recordID) {
            if ([obj[ODRecordSerializationRecordTypeKey] isEqualToString:@"record"]) {
                ODRecordDeserializer *deserializer = [ODRecordDeserializer deserializer];
                record = [deserializer recordWithDictionary:obj];
                
                if (!record) {
                    NSLog(@"Error with returned record.");
                }
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
        
        if (!error && !record) {
            NSMutableDictionary *userInfo = [self errorUserInfoWithLocalizedDescription:@"Record does not conform with expected format."
                                                                        errorDictionary:nil];
            error = [NSError errorWithDomain:(NSString *)ODOperationErrorDomain
                                        code:0
                                    userInfo:userInfo];
        }
        
        if (recordID && self.perRecordCompletionBlock) {
            self.perRecordCompletionBlock(record, recordID, error);
        }
        
        if (record) {
            [recordsByRecordID setObject:record forKey:recordID];
        }
    }];
    
    return recordsByRecordID;
}

- (void)updateCompletionBlock
{
    if (self.perRecordCompletionBlock || self.fetchRecordsCompletionBlock) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            NSDictionary *resultDictionary = nil;
            NSError *error = weakSelf.error;
            if (!error) {
                NSArray *responseArray = weakSelf.response[@"result"];
                if ([responseArray isKindOfClass:[NSArray class]]) {
                    resultDictionary = [weakSelf processResultArray:responseArray];
                } else {
                    NSDictionary *userInfo = [weakSelf errorUserInfoWithLocalizedDescription:@"Server returned malformed result."
                                                                             errorDictionary:nil];
                    error = [NSError errorWithDomain:(NSString *)ODOperationErrorDomain
                                                code:0
                                            userInfo:userInfo];
                }
            }
            
            if (weakSelf.fetchRecordsCompletionBlock) {
                weakSelf.fetchRecordsCompletionBlock(resultDictionary, error);
            }
        };
    }
}

@end
