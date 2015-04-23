//
//  ODSubscriptionDeserializer.h
//  Pods
//
//  Created by Kenji Pa on 22/4/15.
//
//

#import "ODDatabaseOperation.h"
#import "ODSubscription.h"

@interface ODSubscriptionDeserializer : ODDatabaseOperation

+ (instancetype)deserializer;

- (ODSubscription *)subscriptionWithDictionary:(NSDictionary *)dictionary;

@end
