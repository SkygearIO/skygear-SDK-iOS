//
//  ODSubscriptionSerializer.m
//  Pods
//
//  Created by Kenji Pa on 21/4/15.
//
//

#import "ODSubscriptionSerializer.h"
#import "ODQuerySerializer.h"

const NSString *ODSubscriptionSerializationTypeQuery = @"query";

@implementation ODSubscriptionSerializer

+ (instancetype)serializer
{
    return [[ODSubscriptionSerializer alloc] init];
}

- (NSDictionary *)dictionaryWithSubscription:(ODSubscription *)subscription {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    if (subscription.subscriptionID) {
        payload[@"id"] = subscription.subscriptionID;
    }
    switch (subscription.subscriptionType) {
        case ODSubscriptionTypeQuery:
            payload[@"type"] = @"query";
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
