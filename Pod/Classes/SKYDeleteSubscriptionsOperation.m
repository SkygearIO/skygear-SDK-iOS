//
//  SKYDeleteSubscriptionsOperation.m
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

#import "SKYDeleteSubscriptionsOperation.h"
#import "SKYOperationSubclass.h"

#import "SKYDataSerialization.h"
#import "SKYError.h"
#import "SKYSubscription.h"

@implementation SKYDeleteSubscriptionsOperation

- (instancetype)initWithDeviceID:(NSString *)deviceID
         subscriptionIDsToDelete:(NSArray<NSString *> *)subscriptionIDsToDelete;
{
    self = [super init];
    if (self) {
        self.subscriptionIDsToDelete = subscriptionIDsToDelete;
        self.deviceID = deviceID;
    }
    return self;
}

+ (instancetype)operationWithDeviceID:(NSString *)deviceID
              subscriptionIDsToDelete:(NSArray<NSString *> *)subscriptionIDsToDelete;
{
    return [[self alloc] initWithDeviceID:deviceID subscriptionIDsToDelete:subscriptionIDsToDelete];
}

- (void)prepareForRequest
{
    NSMutableDictionary *payload = [@{
        @"database_id" : self.database.databaseID,
    } mutableCopy];

    NSString *deviceID = self.deviceID;
    if (deviceID.length) {
        payload[@"device_id"] = deviceID;
    }

    if (self.subscriptionIDsToDelete.count) {
        payload[@"ids"] = self.subscriptionIDsToDelete;
    }

    self.request = [[SKYRequest alloc] initWithAction:@"subscription:delete" payload:payload];
    self.request.APIKey = self.container.APIKey;
    self.request.accessToken = self.container.currentAccessToken;
}

- (void)processResultArray:(NSArray *)result
    deletedsubscriptionIDs:(NSArray **)deletedsubscriptionIDs
            operationError:(NSError **)operationError
{
    NSMutableArray *subscriptionIDs = [NSMutableArray array];
    NSMutableDictionary *errorBySubscriptionID = [NSMutableDictionary dictionary];

    [result enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSString *objType = obj[@"_type"];
        NSString *subscriptionID = obj[@"id"];
        if ([objType isEqual:@"error"]) {
            subscriptionID = obj[@"_id"];

            NSError *error = [self.errorCreator errorWithResponseDictionary:obj];
            errorBySubscriptionID[subscriptionID] = error;
        } else if (subscriptionID.length) {
            [subscriptionIDs addObject:subscriptionID];
        } else {
            // malformed response
            NSError *error =
                [self.errorCreator errorWithCode:SKYErrorInvalidData
                                         message:@"Missing `id` or not in correct format."];
            errorBySubscriptionID[self.subscriptionIDsToDelete[idx]] = error;
        }
    }];

    if (subscriptionIDs.count) {
        *deletedsubscriptionIDs = subscriptionIDs;
    }
    if (errorBySubscriptionID.count) {
        *operationError =
            [self.errorCreator partialErrorWithPerItemDictionary:errorBySubscriptionID];
    }
}

- (void)handleRequestError:(NSError *)error
{
    if (self.deleteSubscriptionsCompletionBlock) {
        self.deleteSubscriptionsCompletionBlock(nil, error);
    }
}

- (void)handleResponse:(SKYResponse *)responseObject
{
    NSDictionary *response = responseObject.responseDictionary;
    if (self.deleteSubscriptionsCompletionBlock) {
        NSArray *deletedSubscriptions = nil;
        NSError *error = nil;
        NSArray *responseArray = response[@"result"];
        if ([responseArray isKindOfClass:[NSArray class]]) {
            [self processResultArray:responseArray
                deletedsubscriptionIDs:&deletedSubscriptions
                        operationError:&error];
        } else {
            error = [self.errorCreator errorWithCode:SKYErrorBadResponse
                                             message:@"Result is not an array or not exists."];
        }
        self.deleteSubscriptionsCompletionBlock(deletedSubscriptions, error);
    }
}

@end
