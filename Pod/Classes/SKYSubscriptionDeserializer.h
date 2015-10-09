//
//  SKYSubscriptionDeserializer.h
//  Pods
//
//  Created by Kenji Pa on 22/4/15.
//
//

#import "SKYDatabaseOperation.h"
#import "SKYSubscription.h"

@interface SKYSubscriptionDeserializer : SKYDatabaseOperation

+ (instancetype)deserializer;

- (SKYSubscription *)subscriptionWithDictionary:(NSDictionary *)dictionary;

@end
