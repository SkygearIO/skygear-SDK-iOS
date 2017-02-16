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
#import "SKYRecordDeserializer.h"
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
    [self.recordsToSave enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [dictionariesToSave addObject:[serializer dictionaryWithRecord:obj]];
        [recordsByRecordID setObject:obj forKey:[(SKYRecord *)obj recordID]];
    }];

    NSMutableDictionary *payload = [@{
        @"records" : dictionariesToSave,
        @"database_id" : self.database.databaseID,
    } mutableCopy];
    if (self.atomic) {
        payload[@"atomic"] = @YES;
    }

    self.request = [[SKYRequest alloc] initWithAction:@"record:save" payload:payload];
    self.request.accessToken = self.container.currentAccessToken;
}

- (void)handleRequestError:(NSError *)error
{
    if (self.modifyRecordsCompletionBlock) {
        self.modifyRecordsCompletionBlock(nil, error);
    }
}

- (SKYRecordID *)recordIDWithResultItem:(NSDictionary *)item error:(NSError **)error
{
    SKYRecordID *recordID =
        [SKYRecordID recordIDWithCanonicalString:item[SKYRecordSerializationRecordIDKey]];

    if (!recordID) {
        if (error) {
            *error = [self.errorCreator errorWithCode:SKYErrorInvalidData
                                              message:@"Missing `_id` or not in correct format."];
            return nil;
        }
    }
    return recordID;
}

- (SKYRecord *)handleResultItem:(NSDictionary *)item error:(NSError **)error
{
    SKYRecord *record = nil;

    if ([item[SKYRecordSerializationRecordTypeKey] isEqualToString:@"record"]) {
        SKYRecordDeserializer *deserializer = [SKYRecordDeserializer deserializer];
        record = [deserializer recordWithDictionary:item];

        if (!record) {
            NSLog(@"Error with returned record.");
        }
    } else if ([item[SKYRecordSerializationRecordTypeKey] isEqualToString:@"error"]) {
        if (error) {
            *error = [self.errorCreator errorWithResponseDictionary:item];
        }
    }
    return record;
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
    [responseArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSError *error = nil;
        SKYRecordID *recordID = [self recordIDWithResultItem:obj error:&error];
        if (!recordID) {
            if (self.perRecordCompletionBlock) {
                self.perRecordCompletionBlock(nil, error);
            }
            return;
        }

        SKYRecord *record = [self handleResultItem:obj error:&error];
        if (record) {
            [resultArray addObject:record];
        } else if (error) {
            record = self->recordsByRecordID[recordID];
            errorByID[recordID] = error;
        }

        if ((record || error) && self.perRecordCompletionBlock) {
            self.perRecordCompletionBlock(record, error);
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
