//
//  SKYModifySubscriptionsOperation.m
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

#import "SKYModifySubscriptionsOperation.h"
#import "SKYDefaults.h"
#import "SKYSubscriptionSerialization.h"
#import "SKYSubscriptionSerializer.h"
#import "SKYDataSerialization.h"
#import "SKYError.h"

@implementation SKYModifySubscriptionsOperation {
    NSMutableDictionary *subscriptionsByID;
}

- (instancetype)initWithSubscriptionsToSave:(NSArray *)subscriptionsToSave
{
    self = [super init];
    if (self) {
        self.subscriptionsToSave = subscriptionsToSave;
    }
    return self;
}

+ (instancetype)operationWithSubscriptionsToSave:(NSArray *)subscriptionsToSave;
{
    return [[self alloc] initWithSubscriptionsToSave:subscriptionsToSave];
}

- (void)prepareForRequest
{
    SKYSubscriptionSerializer *serializer = [SKYSubscriptionSerializer serializer];

    NSMutableDictionary *payload = [@{
        @"database_id" : self.database.databaseID,
    } mutableCopy];

    NSMutableArray *dictionariesToSave = [NSMutableArray array];
    subscriptionsByID = [NSMutableDictionary dictionary];
    for (SKYSubscription *subscription in self.subscriptionsToSave) {
        [dictionariesToSave addObject:[serializer dictionaryWithSubscription:subscription]];
        subscriptionsByID[subscription.subscriptionID] = subscription;
    }
    if (dictionariesToSave.count) {
        payload[@"subscriptions"] = dictionariesToSave;
    }

    NSString *deviceID = nil;
    if (self.deviceID) {
        deviceID = self.deviceID;
    } else {
        deviceID = [SKYDefaults sharedDefaults].deviceID;
    }
    if (deviceID.length) {
        payload[@"device_id"] = deviceID;
    }

    self.request = [[SKYRequest alloc] initWithAction:@"subscription:save" payload:payload];
    self.request.APIKey = self.container.APIKey;
    self.request.accessToken = self.container.currentAccessToken;
}

- (NSArray *)processResultArray:(NSArray *)result error:(NSError **)operationError
{
    NSMutableDictionary *errorsByID = [NSMutableDictionary dictionary];

    NSMutableArray *savedSubscriptions = [NSMutableArray array];
    for (NSDictionary *dict in result) {
        NSError *error = nil;
        SKYSubscription *subscription = nil;
        NSString *subscriptionID = dict[SKYSubscriptionSerializationSubscriptionIDKey];
        if (subscriptionID.length == 0) {
            subscriptionID =
                dict[@"_id"]; // this is for per item error, which has a different key for ID
        }

        if (subscriptionID) {
            subscription = subscriptionsByID[subscriptionID];
            if (!subscription) {
                NSLog(@"A returned subscription is not requested.");
            }

            NSString *subscriptionType = dict[SKYSubscriptionSerializationSubscriptionTypeKey];
            if ([subscriptionType isEqual:SKYSubscriptionSerializationSubscriptionTypeQuery]) {
                // do nothing
            } else if ([dict[@"_type"] isEqualToString:@"error"]) {
                NSMutableDictionary *userInfo =
                    [SKYDataSerialization userInfoWithErrorDictionary:dict];
                userInfo[NSLocalizedDescriptionKey] = @"An error occurred while modifying record.";
                error = [NSError errorWithDomain:(NSString *)SKYOperationErrorDomain
                                            code:0
                                        userInfo:userInfo];

                [errorsByID setObject:error forKey:subscriptionID];
            }
        }

        if (subscription) {
            [savedSubscriptions addObject:subscription];
        }

        if (self.perSubscriptionCompletionBlock) {
            self.perSubscriptionCompletionBlock(subscription, subscriptionID, error);
        }
    }

    if (operationError && [errorsByID count] > 0) {
        *operationError = [NSError errorWithDomain:SKYOperationErrorDomain
                                              code:SKYErrorPartialFailure
                                          userInfo:@{
                                              SKYPartialErrorsByItemIDKey : errorsByID,
                                          }];
    } else {
        *operationError = nil;
    }

    return savedSubscriptions;
}

- (void)handleRequestError:(NSError *)error
{
    if (self.modifySubscriptionsCompletionBlock) {
        self.modifySubscriptionsCompletionBlock(nil, error);
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
        NSDictionary *userInfo =
            [self errorUserInfoWithLocalizedDescription:@"Server returned malformed results."
                                        errorDictionary:nil];
        error =
            [NSError errorWithDomain:(NSString *)SKYOperationErrorDomain code:0 userInfo:userInfo];
    }

    if (self.modifySubscriptionsCompletionBlock) {
        self.modifySubscriptionsCompletionBlock(resultArray, error);
    }
}

@end
