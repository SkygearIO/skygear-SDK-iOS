//
//  SKYFetchSubscriptionsOperation.m
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

#import "SKYFetchSubscriptionsOperation.h"
#import "SKYDataSerialization.h"
#import "SKYError.h"
#import "SKYOperationSubclass.h"
#import "SKYSubscriptionDeserializer.h"
#import "SKYSubscriptionSerialization.h"

@interface SKYFetchSubscriptionsOperation ()

- (instancetype)initFetchAllWithDeviceID:(NSString *)deviceID NS_DESIGNATED_INITIALIZER;

@property (nonatomic, assign) BOOL isFetchAll;

@end

@implementation SKYFetchSubscriptionsOperation

- (instancetype)initWithDeviceID:(NSString *)deviceID
                 subscriptionIDs:(NSArray<NSString *> *)subscriptionIDs
{
    self = [super init];
    if (self) {
        _deviceID = deviceID;
        _subscriptionIDs = subscriptionIDs;
    }
    return self;
}

- (instancetype)initFetchAllWithDeviceID:(NSString *)deviceID
{
    self = [super init];
    if (self) {
        _deviceID = deviceID;
        _isFetchAll = YES;
    }
    return self;
}

+ (instancetype)operationWithDeviceID:(NSString *)deviceID
                      subscriptionIDs:(NSArray *)subscriptionIDs
{
    return [[self alloc] initWithDeviceID:deviceID subscriptionIDs:subscriptionIDs];
}

+ (instancetype)fetchAllSubscriptionsOperationWithDeviceID:(NSString *)deviceID;
{
    return [[self alloc] initFetchAllWithDeviceID:deviceID];
}

- (void)prepareForRequest
{
    NSMutableArray *subscriptionIDs = [NSMutableArray array];
    for (NSString *subscription in self.subscriptionIDs) {
        [subscriptionIDs addObject:subscription];
    }
    NSMutableDictionary *payload = [@{
        @"database_id" : self.database.databaseID,
    } mutableCopy];

    NSString *deviceID = self.deviceID;
    if (deviceID.length) {
        payload[@"device_id"] = deviceID;
    }

    if (self.isFetchAll) {
        self.request =
            [[SKYRequest alloc] initWithAction:@"subscription:fetch_all" payload:payload];
    } else {
        if (subscriptionIDs.count) {
            payload[@"ids"] = subscriptionIDs;
        }
        self.request = [[SKYRequest alloc] initWithAction:@"subscription:fetch" payload:payload];
    }
    self.request.APIKey = self.container.APIKey;
    self.request.accessToken = self.container.currentAccessToken;
}

- (NSDictionary *)processResultArray:(NSArray *)result error:(NSError **)operationError
{
    SKYSubscriptionDeserializer *deserializer = [SKYSubscriptionDeserializer deserializer];
    NSMutableDictionary *errorsByID = [NSMutableDictionary dictionary];
    NSMutableDictionary *subscriptionsBySubscriptionID = [NSMutableDictionary dictionary];

    for (NSDictionary *dict in result) {
        SKYSubscription *subscription = nil;
        NSError *error = nil;
        NSString *subscriptionID = dict[SKYSubscriptionSerializationSubscriptionIDKey];
        if (subscriptionID.length == 0) {
            subscriptionID =
                dict[@"_id"]; // this is for per item error, which has a different key for ID
        }

        if (subscriptionID.length) {
            if ([self.subscriptionIDs containsObject:subscriptionID]) {
                NSLog(@"A returned subscription is not requested.");
            }

            NSString *subscriptionType = dict[SKYSubscriptionSerializationSubscriptionTypeKey];
            if ([subscriptionType isEqual:SKYSubscriptionSerializationSubscriptionTypeQuery]) {
                subscription = [deserializer subscriptionWithDictionary:dict];
            } else if ([dict[@"_type"] isEqualToString:@"error"]) {
                error = [self.errorCreator errorWithResponseDictionary:dict];
                [errorsByID setObject:error forKey:subscriptionID];
            }
        }

        if (subscription) {
            subscriptionsBySubscriptionID[subscriptionID] = subscription;
        }

        if (self.perSubscriptionCompletionBlock) {
            self.perSubscriptionCompletionBlock(subscription, subscriptionID, error);
        }
    }

    if (operationError && [errorsByID count] > 0) {
        *operationError = [self.errorCreator partialErrorWithPerItemDictionary:errorsByID];
    } else {
        *operationError = nil;
    }

    return subscriptionsBySubscriptionID;
}

- (void)handleRequestError:(NSError *)error
{
    if (self.fetchSubscriptionsCompletionBlock) {
        self.fetchSubscriptionsCompletionBlock(nil, error);
    }
}

- (void)handleResponse:(SKYResponse *)response
{
    NSDictionary *resultDictionary = nil;
    NSError *error = nil;
    NSArray *responseArray = response.responseDictionary[@"result"];
    if ([responseArray isKindOfClass:[NSArray class]]) {
        resultDictionary = [self processResultArray:responseArray error:&error];
    } else {
        error = [self.errorCreator errorWithCode:SKYErrorBadResponse
                                         message:@"Result is not an array or not exists."];
    }

    if (self.fetchSubscriptionsCompletionBlock) {
        self.fetchSubscriptionsCompletionBlock(resultDictionary, error);
    }
}

@end
