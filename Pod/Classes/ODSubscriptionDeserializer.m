//
//  ODSubscriptionDeserializer.m
//  Pods
//
//  Created by Kenji Pa on 22/4/15.
//
//

#import "ODSubscriptionDeserializer.h"
#import "ODSubscriptionSerialization.h"
#import "ODQueryDeserializer.h"

@implementation ODSubscriptionDeserializer

+ (instancetype)deserializer
{
    return [[self alloc] init];
}

- (ODSubscription *)subscriptionWithDictionary:(NSDictionary *)dictionary
{
    NSString *subscriptionID = dictionary[ODSubscriptionSerializationSubscriptionIDKey];
    if (!subscriptionID.length) {
        return nil;
    }

    NSString *subscriptionType = dictionary[ODSubscriptionSerializationSubscriptionTypeKey];
    if (!subscriptionType.length) {
        return nil;
    }

    ODSubscription *subscription;
    if ([subscriptionType isEqualToString:(NSString *)ODSubscriptionSerializationSubscriptionTypeQuery]) {
        NSDictionary* queryDict = dictionary[@"query"];

        ODQueryDeserializer *queryDeserializer = [ODQueryDeserializer deserializer];
        ODQuery *query = [queryDeserializer queryWithDictionary:queryDict];

        subscription = [[ODSubscription alloc] initWithQuery:query subscriptionID:subscriptionID];
    } else {
        NSLog(@"Unrecgonized subscription type = %@", subscriptionType);
    }

    return subscription;
}

@end
