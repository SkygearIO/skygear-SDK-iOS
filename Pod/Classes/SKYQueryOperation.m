//
//  SKYQueryOperation.m
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

#import "SKYQueryOperation.h"
#import "SKYDataSerialization.h"
#import "SKYOperationSubclass.h"
#import "SKYQuerySerializer.h"
#import "SKYRecordDeserializer.h"
#import "SKYRecordSerialization.h"

@interface SKYQueryOperation ()

@property SKYQueryCursor *cursor;

@end

@implementation SKYQueryOperation

- (instancetype)initWithQuery:(SKYQuery *)query
{
    self = [super init];
    if (self) {
        _query = query;
    }
    return self;
}

- (instancetype)initWithCursor:(SKYQueryCursor *)cursor
{
    self = [super init];
    if (self) {
        _cursor = cursor;
    }
    return self;
}

+ (instancetype)operationWithQuery:(SKYQuery *)query
{
    return [[self alloc] initWithQuery:query];
}

+ (instancetype)operationWithCursor:(SKYQueryCursor *)cursor
{
    return [[self alloc] initWithCursor:cursor];
}

- (void)prepareForRequest
{
    SKYQuerySerializer *serializer = [SKYQuerySerializer serializer];
    NSMutableDictionary *payload = [serializer serializeWithQuery:self.query];
    payload[@"database_id"] = self.database.databaseID;
    self.request = [[SKYRequest alloc] initWithAction:@"record:query" payload:payload];

    self.request.APIKey = self.container.APIKey;
    self.request.accessToken = self.container.currentAccessToken;
}

- (NSArray *)processResultArray:(NSArray *)result
                 perRecordBlock:(void (^)(SKYRecord *record))perRecordBlock
{
    NSMutableArray *fetchedRecords = [NSMutableArray array];
    SKYRecordDeserializer *deserializer = [SKYRecordDeserializer deserializer];

    [result enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSError *error = nil;
        SKYRecord *record = nil;
        SKYRecordID *recordID =
            [SKYRecordID recordIDWithCanonicalString:obj[SKYRecordSerializationRecordIDKey]];

        if (recordID) {
            NSString *type = obj[SKYRecordSerializationRecordTypeKey];
            if ([type isEqualToString:@"record"]) {
                record = [deserializer recordWithDictionary:obj];

                if (!record) {
                    NSLog(@"Warning: Received malformed record dictionary.");
                }
            } else {
                // not expecting an error here.
                NSLog(@"Warning: Received dictionary with unexpected value (%@) in `%@` key.", type,
                      SKYRecordSerializationRecordTypeKey);
            }
        } else {
            error = [self.errorCreator errorWithCode:SKYErrorInvalidData
                                             message:@"Missing `_id` or not in correct format."];
        }

        if (record) {
            [fetchedRecords addObject:record];
            if (perRecordBlock) {
                perRecordBlock(record);
            }
        }
    }];

    return fetchedRecords;
}

- (void)processResultInfo:(NSDictionary *)resultInfo
{
    if (![resultInfo isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [self willChangeValueForKey:@"overallCount"];
    _overallCount = [resultInfo[@"count"] unsignedIntegerValue];
    [self didChangeValueForKey:@"overallCount"];
}

- (void)handleRequestError:(NSError *)error
{
    if (self.queryRecordsCompletionBlock) {
        self.queryRecordsCompletionBlock(nil, nil, error);
    }
}

- (void)handleResponse:(SKYResponse *)responseObject
{
    NSDictionary *response = responseObject.responseDictionary;
    NSArray *resultArray;
    NSError *error = nil;
    NSArray *responseArray = response[@"result"];

    [self processResultInfo:response[@"info"]];

    if ([responseArray isKindOfClass:[NSArray class]]) {
        resultArray = [self processResultArray:responseArray
                                perRecordBlock:^(SKYRecord *record) {
                                    if (self.perRecordCompletionBlock) {
                                        self.perRecordCompletionBlock(record);
                                    }
                                }];
    } else {
        error = [self.errorCreator errorWithCode:SKYErrorBadResponse
                                         message:@"Result is not an array or not exists."];
    }

    if (self.queryRecordsCompletionBlock) {
        self.queryRecordsCompletionBlock(resultArray, nil, error);
    }
}

@end
