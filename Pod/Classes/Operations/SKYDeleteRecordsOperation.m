//
//  SKYDeleteRecordsOperation.m
//  SKYKit
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
//

#import "SKYDeleteRecordsOperation.h"
#import "SKYOperationSubclass.h"

#import "SKYRecordSerialization.h"
#import "SKYDataSerialization.h"
#import "SKYError.h"

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

- (NSArray *)processResultArray:(NSArray *)result error:(NSError **)operationError
{
    NSMutableDictionary *errorsByID = [NSMutableDictionary dictionary];
    NSMutableArray *deletedRecordIDs = [self.recordIDs mutableCopy];
    [result enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSError *error = nil;
        SKYRecordID *recordID =
            [SKYRecordID recordIDWithCanonicalString:obj[SKYRecordSerializationRecordIDKey]];

        if (recordID) {
            if ([obj[SKYRecordSerializationRecordTypeKey] isEqualToString:@"error"]) {
                error = [self.errorCreator errorWithResponseDictionary:obj];
                [errorsByID setObject:error forKey:recordID];
            }
        } else {
            error = [self.errorCreator errorWithCode:SKYErrorInvalidData
                                             message:@"Missing `_id` or not in correct format."];
        }

        if (recordID) {
            if (self.perRecordCompletionBlock) {
                self.perRecordCompletionBlock(recordID, error);
            }
            [deletedRecordIDs removeObject:recordID];
        }
    }];

    if (operationError && [errorsByID count] > 0) {
        *operationError = [NSError errorWithDomain:SKYOperationErrorDomain
                                              code:SKYErrorPartialFailure
                                          userInfo:@{
                                              SKYPartialErrorsByItemIDKey : errorsByID,
                                          }];
    } else {
        *operationError = nil;
    }

    if (self.perRecordCompletionBlock) {
        [deletedRecordIDs
            enumerateObjectsUsingBlock:^(SKYRecordID *recordID, NSUInteger idx, BOOL *stop) {
                self.perRecordCompletionBlock(recordID, nil);
            }];
    }

    return deletedRecordIDs;
}

- (void)handleRequestError:(NSError *)error
{
    if (self.deleteRecordsCompletionBlock) {
        self.deleteRecordsCompletionBlock(nil, error);
    }
}

- (void)handleResponse:(SKYResponse *)response
{
    NSArray *resultArray = nil;
    NSError *error = nil;
    NSArray *responseArray = response.responseDictionary[@"result"];
    if ([responseArray isKindOfClass:[NSArray class]]) {
        resultArray = [self processResultArray:responseArray error:&error];
    } else {
        error = [self.errorCreator errorWithCode:SKYErrorBadResponse
                                         message:@"Result is not an array or not exists."];
    }

    if (self.deleteRecordsCompletionBlock) {
        self.deleteRecordsCompletionBlock(resultArray, error);
    }
}

@end
