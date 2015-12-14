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
#import "SKYOperation_Private.h"
#import "SKYDefaults.h"
#import "SKYSubscriptionDeserializer.h"
#import "SKYSubscriptionSerialization.h"

@interface SKYFetchSubscriptionsOperation ()

- (instancetype)initFetchAll NS_DESIGNATED_INITIALIZER;

@property (nonatomic, assign) BOOL isFetchAll;

@end

@implementation SKYFetchSubscriptionsOperation

- (instancetype)initWithSubscriptionIDs:(NSArray *)subscriptionIDs
{
    self = [super init];
    if (self) {
        _subscriptionIDs = subscriptionIDs;
    }
    return self;
}

- (instancetype)initFetchAll
{
    self = [super init];
    if (self) {
        _isFetchAll = YES;
    }
    return self;
}

+ (instancetype)operationWithSubscriptionIDs:(NSArray *)subscriptionIDs
{
    return [[self alloc] initWithSubscriptionIDs:subscriptionIDs];
}

+ (instancetype)fetchAllSubscriptionsOperation
{
    return [[self alloc] initFetchAll];
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

    NSString *deviceID = nil;
    if (self.deviceID) {
        deviceID = self.deviceID;
    } else {
        deviceID = [SKYDefaults sharedDefaults].deviceID;
    }
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

- (void)setFetchSubscriptionCompletionBlock:
    (void (^)(NSDictionary *subscriptionsBySubscriptionID,
              NSError *operationError))fetchSubscriptionCompletionBlock
{
    [self willChangeValueForKey:@"fetchSubscriptionCompletionBlock"];
    _fetchSubscriptionCompletionBlock = fetchSubscriptionCompletionBlock;
    [self updateCompletionBlock];
    [self didChangeValueForKey:@"fetchSubscriptionCompletionBlock"];
}

- (NSDictionary *)processResultArray:(NSArray *)result
{
    SKYSubscriptionDeserializer *deserializer = [SKYSubscriptionDeserializer deserializer];
    NSMutableDictionary *subscriptionsBySubscriptionID = [NSMutableDictionary dictionary];

    for (NSDictionary *dict in result) {
        SKYSubscription *subscription = nil;
        NSString *subscriptionID = dict[SKYSubscriptionSerializationSubscriptionIDKey];
        if (subscriptionID.length) {
            if ([self.subscriptionIDs containsObject:subscriptionID]) {
                NSLog(@"A returned subscription is not requested.");
            }

            NSString *subscriptionType = dict[SKYSubscriptionSerializationSubscriptionTypeKey];
            if ([subscriptionType isEqual:SKYSubscriptionSerializationSubscriptionTypeQuery]) {
                subscription = [deserializer subscriptionWithDictionary:dict];
            }
        }

        if (subscription) {
            subscriptionsBySubscriptionID[subscriptionID] = subscription;
        }
    }
    return subscriptionsBySubscriptionID;
}

- (void)updateCompletionBlock
{
    if (self.fetchSubscriptionCompletionBlock) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            NSDictionary *resultDictionary = nil;
            NSError *error = weakSelf.error;
            if (!error) {
                NSArray *responseArray = weakSelf.response[@"result"];
                if ([responseArray isKindOfClass:[NSArray class]]) {
                    resultDictionary = [weakSelf processResultArray:responseArray];
                } else {
                    NSDictionary *userInfo = [weakSelf
                        errorUserInfoWithLocalizedDescription:@"Server returned malformed result."
                                              errorDictionary:nil];
                    error = [NSError errorWithDomain:(NSString *)SKYOperationErrorDomain
                                                code:0
                                            userInfo:userInfo];
                }
            }

            if (weakSelf.fetchSubscriptionCompletionBlock) {
                weakSelf.fetchSubscriptionCompletionBlock(resultDictionary, error);
            }
        };
    } else {
        self.completionBlock = nil;
    }
}

@end
