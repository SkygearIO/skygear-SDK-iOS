//
//  SKYDeleteRecordsOperation.m
//  SkyKit
//
//  Copyright 2015 Oursky Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "SKYDeleteRecordsOperation.h"
#import "SKYOperation_Private.h"
#import "SKYRecordSerialization.h"
#import "SKYDataSerialization.h"

@implementation SKYDeleteRecordsOperation

- (instancetype)initWithRecordIDsToDelete:(NSArray *)recordIDs
{
    self = [super init];
    if (self) {
        self.recordIDs = [recordIDs copy];
    }
    return self;
}

+ (instancetype)operationWithRecordIDsToDelete:(NSArray *)recordIDs
{
    return [[self alloc] initWithRecordIDsToDelete:recordIDs];
}

- (void)prepareForRequest
{
    NSMutableArray *stringIDs = [NSMutableArray array];
    [self.recordIDs enumerateObjectsUsingBlock:^(SKYRecordID *obj, NSUInteger idx, BOOL *stop) {
        [stringIDs addObject:[obj canonicalString]];
    }];

    NSMutableDictionary *payload = [@{
        @"ids" : stringIDs,
        @"database_id" : self.database.databaseID,
    } mutableCopy];
    if (self.atomic) {
        payload[@"atomic"] = @YES;
    }

    self.request = [[SKYRequest alloc] initWithAction:@"record:delete" payload:payload];
    self.request.accessToken = self.container.currentAccessToken;
}

- (void)setPerRecordCompletionBlock:(void (^)(SKYRecordID *, NSError *))perRecordCompletionBlock
{
    [self willChangeValueForKey:@"perRecordCompletionBlock"];
    _perRecordCompletionBlock = perRecordCompletionBlock;
    [self updateCompletionBlock];
    [self didChangeValueForKey:@"perRecordCompletionBlock"];
}

- (void)setDeleteRecordsCompletionBlock:(void (^)(NSArray *, NSError *))deleteRecordsCompletionBlock
{
    [self willChangeValueForKey:@"deleteRecordsCompletionBlock"];
    _deleteRecordsCompletionBlock = deleteRecordsCompletionBlock;
    [self updateCompletionBlock];
    [self didChangeValueForKey:@"deleteRecordsCompletionBlock"];
}

- (NSArray *)processResultArray:(NSArray *)result
{
    NSMutableArray *deletedRecordIDs = [self.recordIDs mutableCopy];
    [result enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSError *error = nil;
        SKYRecordID *recordID =
            [SKYRecordID recordIDWithCanonicalString:obj[SKYRecordSerializationRecordIDKey]];

        if (recordID) {
            if ([obj[SKYRecordSerializationRecordTypeKey] isEqualToString:@"error"]) {
                NSMutableDictionary *userInfo =
                    [SKYDataSerialization userInfoWithErrorDictionary:obj];
                userInfo[NSLocalizedDescriptionKey] = @"An error occurred while modifying record.";
                error = [NSError errorWithDomain:(NSString *)SKYOperationErrorDomain
                                            code:0
                                        userInfo:userInfo];
            }
        } else {
            NSMutableDictionary *userInfo = [self
                errorUserInfoWithLocalizedDescription:@"Missing `_id` or not in correct format."
                                      errorDictionary:nil];
            error = [NSError errorWithDomain:(NSString *)SKYOperationErrorDomain
                                        code:0
                                    userInfo:userInfo];
        }

        if (recordID) {
            if (self.perRecordCompletionBlock) {
                self.perRecordCompletionBlock(recordID, error);
            }
            [deletedRecordIDs removeObject:recordID];
        }
    }];

    if (self.perRecordCompletionBlock) {
        [deletedRecordIDs
            enumerateObjectsUsingBlock:^(SKYRecordID *recordID, NSUInteger idx, BOOL *stop) {
                self.perRecordCompletionBlock(recordID, nil);
            }];
    }

    return deletedRecordIDs;
}

- (void)updateCompletionBlock
{
    if (self.perRecordCompletionBlock || self.deleteRecordsCompletionBlock) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            NSArray *resultArray = nil;
            NSError *error = weakSelf.error;
            if (!error) {
                NSArray *responseArray = weakSelf.response[@"result"];
                if ([responseArray isKindOfClass:[NSArray class]]) {
                    resultArray = [weakSelf processResultArray:responseArray];
                } else {
                    NSDictionary *userInfo = [weakSelf
                        errorUserInfoWithLocalizedDescription:@"Server returned malformed result."
                                              errorDictionary:nil];
                    error = [NSError errorWithDomain:(NSString *)SKYOperationErrorDomain
                                                code:0
                                            userInfo:userInfo];
                }
            }

            if (weakSelf.deleteRecordsCompletionBlock) {
                weakSelf.deleteRecordsCompletionBlock(resultArray, error);
            }
        };
    }
}

@end
