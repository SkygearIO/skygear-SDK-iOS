//
//  SKYSubscriptionDeserializer.m
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

#import "SKYSubscriptionDeserializer.h"
#import "SKYNotificationInfoDeserializer.h"
#import "SKYQueryDeserializer.h"
#import "SKYSubscriptionSerialization.h"

@implementation SKYSubscriptionDeserializer

+ (instancetype)deserializer
{
    return [[self alloc] init];
}

- (SKYSubscription *)subscriptionWithDictionary:(NSDictionary *)dictionary
{
    NSString *subscriptionID = dictionary[SKYSubscriptionSerializationSubscriptionIDKey];
    if (!subscriptionID.length) {
        return nil;
    }

    NSString *subscriptionType = dictionary[SKYSubscriptionSerializationSubscriptionTypeKey];
    if (!subscriptionType.length) {
        return nil;
    }

    SKYSubscription *subscription;
    if ([subscriptionType
            isEqualToString:(NSString *)SKYSubscriptionSerializationSubscriptionTypeQuery]) {
        NSDictionary *queryDict = dictionary[@"query"];

        SKYQueryDeserializer *queryDeserializer = [SKYQueryDeserializer deserializer];
        SKYQuery *query = [queryDeserializer queryWithDictionary:queryDict];

        subscription = [[SKYSubscription alloc] initWithQuery:query subscriptionID:subscriptionID];
    } else {
        NSLog(@"Unrecgonized subscription type = %@", subscriptionType);
    }

    SKYNotificationInfoDeserializer *notificationInfoDeserializer =
        [SKYNotificationInfoDeserializer deserializer];

    SKYNotificationInfo *notificationInfo = [notificationInfoDeserializer
        notificationInfoWithDictionary:dictionary[@"notification_info"]];
    subscription.notificationInfo = notificationInfo;

    return subscription;
}

@end
