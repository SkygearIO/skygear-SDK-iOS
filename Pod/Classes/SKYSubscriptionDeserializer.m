//
//  SKYSubscriptionDeserializer.m
//  Pods
//
//  Created by Kenji Pa on 22/4/15.
//
//

#import "SKYSubscriptionDeserializer.h"
#import "SKYSubscriptionSerialization.h"
#import "SKYNotificationInfoDeserializer.h"
#import "SKYQueryDeserializer.h"

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
    if ([subscriptionType isEqualToString:(NSString *)SKYSubscriptionSerializationSubscriptionTypeQuery]) {
        NSDictionary* queryDict = dictionary[@"query"];

        SKYQueryDeserializer *queryDeserializer = [SKYQueryDeserializer deserializer];
        SKYQuery *query = [queryDeserializer queryWithDictionary:queryDict];

        subscription = [[SKYSubscription alloc] initWithQuery:query subscriptionID:subscriptionID];
    } else {
        NSLog(@"Unrecgonized subscription type = %@", subscriptionType);
    }

    SKYNotificationInfoDeserializer *notificationInfoDeserializer = [SKYNotificationInfoDeserializer deserializer];

    SKYNotificationInfo *notificationInfo = [notificationInfoDeserializer notificationInfoWithDictionary:dictionary[@"notification_info"]];
    subscription.notificationInfo = notificationInfo;

    return subscription;
}

@end
