//
//  SKYSubscriptionSerializer.m
//  Pods
//
//  Created by Kenji Pa on 21/4/15.
//
//

#import "SKYSubscriptionSerializer.h"
#import "SKYSubscriptionSerialization.h"
#import "SKYQuerySerializer.h"
#import "SKYNotificationInfoSerializer.h"

@implementation SKYSubscriptionSerializer

+ (instancetype)serializer
{
    return [[SKYSubscriptionSerializer alloc] init];
}

- (NSDictionary *)dictionaryWithSubscription:(SKYSubscription *)subscription {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    if (subscription.subscriptionID) {
        payload[SKYSubscriptionSerializationSubscriptionIDKey] = subscription.subscriptionID;
    }

    NSDictionary *notificationInfoDict;
    switch (subscription.subscriptionType) {
        case SKYSubscriptionTypeQuery:
            payload[SKYSubscriptionSerializationSubscriptionTypeKey] = SKYSubscriptionSerializationSubscriptionTypeQuery;
            if (subscription.query) {
                payload[@"query"] = [[SKYQuerySerializer serializer] serializeWithQuery:subscription.query];
            }

            notificationInfoDict = [[SKYNotificationInfoSerializer serializer] dictionaryWithNotificationInfo:subscription.notificationInfo];
            if (notificationInfoDict.count) {
                payload[@"notification_info"] = notificationInfoDict;
            }
            break;
        default:
            @throw [NSException exceptionWithName:@"UnrecgonizedSubscriptionType" reason:[NSString stringWithFormat:@"Unrecgonized SubscriptionType: %@", @(subscription.subscriptionType)] userInfo:nil];
    }
    return payload;
}

@end
