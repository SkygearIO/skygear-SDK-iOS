//
//  SKYModifyRecordsOperation.m
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

#import "SKYModifyRecordsOperation.h"
#import "SKYOperation_Private.h"
#import "SKYRecordSerializer.h"
#import "SKYRecordSerialization.h"
#import "SKYDataSerialization.h"
#import "SKYRecordDeserializer.h"
#import "SKYError.h"

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
        NSMutableDictionary *userInfo =
            [self errorUserInfoWithLocalizedDescription:@"Missing `_id` or not in correct format."
                                        errorDictionary:nil];
        if (error) {
            *error = [NSError errorWithDomain:(NSString *)SKYOperationErrorDomain
                                         code:0
                                     userInfo:userInfo];
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
        NSMutableDictionary *userInfo = [SKYDataSerialization userInfoWithErrorDictionary:item];
        userInfo[NSLocalizedDescriptionKey] = @"An error occurred while modifying record.";
        if (error) {
            *error = [NSError errorWithDomain:(NSString *)SKYOperationErrorDomain
                                         code:0
                                     userInfo:userInfo];
            return nil;
        }
    }
    return record;
}

- (NSArray *)handleResponseArray:(NSArray *)responseArray error:(NSError **)error
{
    if (!responseArray) {
        NSDictionary *userInfo =
            [self errorUserInfoWithLocalizedDescription:@"Server returned malformed result."
                                        errorDictionary:nil];
        if (error) {
            *error = [NSError errorWithDomain:(NSString *)SKYOperationErrorDomain
                                         code:0
                                     userInfo:userInfo];
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
        *error = [NSError errorWithDomain:SKYOperationErrorDomain
                                     code:SKYErrorPartialFailure
                                 userInfo:@{
                                     SKYPartialErrorsByItemIDKey : errorByID,
                                 }];
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
