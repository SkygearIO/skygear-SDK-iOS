//
//  SKYSubscriptionSerializer.m
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

#import "SKYSubscriptionSerializer.h"
#import "SKYNotificationInfoSerializer.h"
#import "SKYQuerySerializer.h"
#import "SKYSubscriptionSerialization.h"

@implementation SKYSubscriptionSerializer

+ (instancetype)serializer
{
    return [[SKYSubscriptionSerializer alloc] init];
}

- (NSDictionary *)dictionaryWithSubscription:(SKYSubscription *)subscription
{
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    if (subscription.subscriptionID) {
        payload[SKYSubscriptionSerializationSubscriptionIDKey] = subscription.subscriptionID;
    }

    NSDictionary *notificationInfoDict;
    switch (subscription.subscriptionType) {
        case SKYSubscriptionTypeQuery:
            payload[SKYSubscriptionSerializationSubscriptionTypeKey] =
                SKYSubscriptionSerializationSubscriptionTypeQuery;
            if (subscription.query) {
                payload[@"query"] =
                    [[SKYQuerySerializer serializer] serializeWithQuery:subscription.query];
            }

            notificationInfoDict = [[SKYNotificationInfoSerializer serializer]
                dictionaryWithNotificationInfo:subscription.notificationInfo];
            if (notificationInfoDict.count) {
                payload[@"notification_info"] = notificationInfoDict;
            }
            break;
        default:
            @throw [NSException
                exceptionWithName:@"UnrecgonizedSubscriptionType"
                           reason:[NSString stringWithFormat:@"Unrecgonized SubscriptionType: %@",
                                                             @(subscription.subscriptionType)]
                         userInfo:nil];
    }
    return payload;
}

@end
