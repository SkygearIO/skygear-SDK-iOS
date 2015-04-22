//
//  ODSubscriptionSerializer.m
//  Pods
//
//  Created by Kenji Pa on 21/4/15.
//
//

#import "ODSubscriptionSerializer.h"
#import "ODSubscriptionSerialization.h"
#import "ODQuerySerializer.h"

@implementation ODSubscriptionSerializer

+ (instancetype)serializer
{
    return [[ODSubscriptionSerializer alloc] init];
}

- (NSDictionary *)dictionaryWithSubscription:(ODSubscription *)subscription {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    if (subscription.subscriptionID) {
        payload[ODSubscriptionSerializationSubscriptionIDKey] = subscription.subscriptionID;
    }
    switch (subscription.subscriptionType) {
        case ODSubscriptionTypeQuery:
            payload[ODSubscriptionSerializationSubscriptionTypeKey] = ODSubscriptionSerializationSubscriptionTypeQuery;
            if (subscription.query) {
                payload[@"query"] = [[ODQuerySerializer serializer] serializeWithQuery:subscription.query];
            }
            break;
        default:
            @throw [NSException exceptionWithName:@"UnrecgonizedSubscriptionType" reason:[NSString stringWithFormat:@"Unrecgonized SubscriptionType: %@", @(subscription.subscriptionType)] userInfo:nil];
    }
    return payload;
}

@end
