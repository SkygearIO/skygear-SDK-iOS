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
#import "SKYQueryInfo_Private.h"
#import "SKYQuerySerializer.h"
#import "SKYRecordResponseDeserializer.h"
#import "SKYRecordSerialization.h"

@interface SKYQueryOperation ()

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

+ (instancetype)operationWithQuery:(SKYQuery *)query
{
    return [[self alloc] initWithQuery:query];
}

- (void)prepareForRequest
{
    SKYQuerySerializer *serializer = [SKYQuerySerializer serializer];
    NSMutableDictionary *payload = [serializer serializeWithQuery:self.query];
    payload[@"database_id"] = self.database.databaseID;
    self.request = [[SKYRequest alloc] initWithAction:@"record:query" payload:payload];

    self.request.APIKey = self.container.APIKey;
    self.request.accessToken = self.container.auth.currentAccessToken;
}

- (NSArray *)processResultArray:(NSArray *)result
                 perRecordBlock:(void (^)(SKYRecord *record))perRecordBlock
{
    NSMutableArray *fetchedRecords = [NSMutableArray array];
    SKYRecordResponseDeserializer *deserializer = [[SKYRecordResponseDeserializer alloc] init];

    [deserializer
        deserializeResponseArray:result
                           block:^(NSString *recordType, NSString *recordID, SKYRecord *record,
                                   NSError *error) {
                               if (error) {
                                   NSLog(@"Record does not conform with expected format.");
                                   return;
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

    SKYQueryInfo *queryInfo = [[SKYQueryInfo alloc] init];
    queryInfo.overallCount = _overallCount;

    if ([responseArray isKindOfClass:[NSArray class]]) {
        resultArray = [self processResultArray:responseArray
                                perRecordBlock:^(SKYRecord *record) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
                                    if (self.perRecordCompletionBlock) {
                                        self.perRecordCompletionBlock(record);
                                    }
#pragma GCC diagnostic pop
                                }];
    } else {
        error = [self.errorCreator errorWithCode:SKYErrorBadResponse
                                         message:@"Result is not an array or not exists."];
    }

    if (self.queryRecordsCompletionBlock) {
        self.queryRecordsCompletionBlock(resultArray, queryInfo, error);
    }
}

@end
