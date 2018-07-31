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

#import "SKYDataSerialization.h"
#import "SKYError.h"
#import "SKYRecordResponseDeserializer.h"
#import "SKYRecordSerialization.h"
#import "SKYRecord_Private.h"

@implementation SKYDeleteRecordsOperation {
    NSArray<NSString *> *_recordTypes;
    NSArray<NSString *> *_recordIDs;
}

- (instancetype)initWithRecordTypes:(NSArray<NSString *> *)recordTypes
                          recordIDs:(NSArray<NSString *> *)recordIDs
{
    if ([recordTypes count] != [recordIDs count]) {
        NSString *reason = [NSString
            stringWithFormat:@"The number of record IDs (%lu) does not match the number "
                             @"of the record types (%lu).",
                             (unsigned long)[recordIDs count], (unsigned long)[recordTypes count]];
        @throw
            [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
    }

    if ((self = [super init])) {
        _recordTypes = [recordTypes copy];
        _recordIDs = [recordIDs copy];
    }
    return self;
}

- (instancetype)initWithRecords:(NSArray<SKYRecord *> *)records
{
    NSMutableArray<NSString *> *recordTypes = [NSMutableArray array];
    NSMutableArray<NSString *> *recordIDs = [NSMutableArray array];

    for (SKYRecord *record in records) {
        [recordTypes addObject:record.recordType];
        [recordIDs addObject:record.recordID];
    }

    return [self initWithRecordTypes:recordTypes recordIDs:recordIDs];
}

- (instancetype)initWithRecordType:(NSString *)recordType recordIDs:(NSArray<NSString *> *)recordIDs
{
    NSMutableArray<NSString *> *recordTypes = [NSMutableArray array];

    for (NSUInteger i = 0; i < [recordIDs count]; i++) {
        [recordTypes addObject:recordType];
    }

    return [self initWithRecordTypes:recordTypes recordIDs:recordIDs];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

- (instancetype)initWithRecordIDsToDelete:(NSArray<SKYRecordID *> *)deprecatedIDs
{
    NSMutableArray<NSString *> *recordTypes = [NSMutableArray array];
    NSMutableArray<NSString *> *recordIDs = [NSMutableArray array];

    for (SKYRecordID *deprecatedID in deprecatedIDs) {
        [recordTypes addObject:deprecatedID.recordType];
        [recordIDs addObject:deprecatedID.recordName];
    }

    return [self initWithRecordTypes:recordTypes recordIDs:recordIDs];
}

#pragma GCC diagnostic pop

+ (instancetype)operationWithRecords:(NSArray<SKYRecord *> *)records
{
    return [[SKYDeleteRecordsOperation alloc] initWithRecords:records];
}

+ (instancetype)operationWithRecordType:(NSString *)recordType
                              recordIDs:(NSArray<NSString *> *)recordIDs
{
    return [[SKYDeleteRecordsOperation alloc] initWithRecordType:recordType recordIDs:recordIDs];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

+ (instancetype)operationWithRecordIDsToDelete:(NSArray<SKYRecordID *> *)recordIDs
{
    return [[SKYDeleteRecordsOperation alloc] initWithRecordIDsToDelete:recordIDs];
}

#pragma GCC diagnostic pop

- (void)prepareForRequest
{
    NSMutableArray<NSDictionary<NSString *, NSString *> *> *recordDictionaries =
        [NSMutableArray array];
    NSMutableArray *deprecatedIDs = [NSMutableArray array];
    for (NSUInteger i = 0; i < _recordTypes.count; i++) {
        [recordDictionaries addObject:@{
            @"_recordType" : _recordTypes[i],
            @"_recordID" : _recordIDs[i],
        }];
        [deprecatedIDs addObject:SKYRecordConcatenatedID(_recordTypes[i], _recordIDs[i])];
    }

    NSMutableDictionary *payload = [@{
        @"ids" : deprecatedIDs,
        @"records" : recordDictionaries,
        @"database_id" : self.database.databaseID,
    } mutableCopy];
    if (self.atomic) {
        payload[@"atomic"] = @YES;
    }

    self.request = [[SKYRequest alloc] initWithAction:@"record:delete" payload:payload];
    self.request.accessToken = self.container.auth.currentAccessToken;
}

- (void)handleRequestError:(NSError *)error
{
    if (self.deleteRecordsCompletionBlock) {
        self.deleteRecordsCompletionBlock(nil, error);
    }
}

- (void)handleResponse:(SKYResponse *)response
{
    if (!self.deleteRecordsCompletionBlock) {
        return;
    }

    NSArray *responseArray = response.responseDictionary[@"result"];
    if (![responseArray isKindOfClass:[NSArray class]]) {
        NSError *error = [self.errorCreator errorWithCode:SKYErrorBadResponse
                                                  message:@"Result is not an array or not exists."];
        self.deleteRecordsCompletionBlock(nil, error);
        return;
    }

    NSMutableArray<SKYRecordResult<SKYRecord *> *> *results = [NSMutableArray array];
    SKYRecordResponseDeserializer *deserializer = [[SKYRecordResponseDeserializer alloc] init];
    [responseArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        [deserializer
            deserializeResponseDictionary:obj
                                    block:^(NSString *recordType, NSString *recordID,
                                            SKYRecord *record, NSError *error) {
                                        if (error) {
                                            [results addObject:[[SKYRecordResult<SKYRecord *> alloc]
                                                                   initWithError:error]];
                                        } else {
                                            record = [SKYRecord deletedRecordWithType:recordType
                                                                             recordID:recordID];
                                            [results addObject:[[SKYRecordResult<SKYRecord *> alloc]
                                                                   initWithValue:record]];
                                        }
                                    }];
    }];
    self.deleteRecordsCompletionBlock(results, nil);
}

@end
