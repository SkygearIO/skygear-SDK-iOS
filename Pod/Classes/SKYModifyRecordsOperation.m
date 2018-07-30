//
//  SKYModifyRecordsOperation.m
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

#import "SKYModifyRecordsOperation.h"
#import "SKYDataSerialization.h"
#import "SKYError.h"
#import "SKYOperationSubclass.h"
#import "SKYOperation_Private.h"
#import "SKYRecordResponseDeserializer.h"
#import "SKYRecordSerialization.h"
#import "SKYRecordSerializer.h"

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
    [self.recordsToSave
        enumerateObjectsUsingBlock:^(SKYRecord *record, NSUInteger idx, BOOL *stop) {
            [dictionariesToSave addObject:[serializer dictionaryWithRecord:record]];
            [self->recordsByRecordID
                setObject:record
                   forKey:SKYRecordConcatenatedID(record.recordType, record.recordID)];
        }];

    NSMutableDictionary *payload = [@{
        @"records" : dictionariesToSave,
        @"database_id" : self.database.databaseID,
    } mutableCopy];
    if (self.atomic) {
        payload[@"atomic"] = @YES;
    }

    self.request = [[SKYRequest alloc] initWithAction:@"record:save" payload:payload];
    self.request.accessToken = self.container.auth.currentAccessToken;
}

- (void)handleRequestError:(NSError *)error
{
    if (self.modifyRecordsCompletionBlock) {
        self.modifyRecordsCompletionBlock(nil, error);
    }
}

- (NSArray *)handleResponseArray:(NSArray *)responseArray error:(NSError **)error
{
    if (!responseArray) {
        if (error) {
            *error = [self.errorCreator errorWithCode:SKYErrorBadResponse
                                              message:@"Result is not an array or not exists."];
        }
        return nil;
    }

    NSMutableDictionary *errorByID = [NSMutableDictionary dictionary];
    NSMutableArray *resultArray = [NSMutableArray array];
    SKYRecordResponseDeserializer *deserializer = [[SKYRecordResponseDeserializer alloc] init];
    [deserializer
        deserializeResponseArray:responseArray
                           block:^(NSString *recordType, NSString *recordID, SKYRecord *record,
                                   NSError *error) {
                               SKYRecord *rtnRecord = record;

                               if (error) {
                                   NSString *concatenatedID =
                                       SKYRecordConcatenatedID(recordType, recordID);
                                   if (recordType && recordID) {
                                       errorByID[concatenatedID] = error;
                                   }
                                   rtnRecord = self->recordsByRecordID[concatenatedID];
                               }

                               if (record) {
                                   [resultArray addObject:record];
                               }

                               if ((rtnRecord || error) && self.perRecordCompletionBlock) {
                                   self.perRecordCompletionBlock(rtnRecord, error);
                               }
                           }];

    if ([errorByID count] && error) {
        *error = [self.errorCreator partialErrorWithPerItemDictionary:errorByID];
    }
    return resultArray;
}

- (void)handleResponse:(SKYResponse *)responseObject
{
    NSDictionary *response = responseObject.responseDictionary;
    NSError *operationError = nil;
    NSArray *responseArray = [self handleResponseArray:response[@"result"] error:&operationError];

    if (self.modifyRecordsCompletionBlock) {
        self.modifyRecordsCompletionBlock(responseArray, operationError);
    }
}

@end
