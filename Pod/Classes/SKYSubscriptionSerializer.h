//
//  SKYSubscriptionSerializer.h
//  Pods
//
//  Created by Kenji Pa on 21/4/15.
//
//

#import <Foundation/Foundation.h>

#import "SKYSubscription.h"

@interface SKYSubscriptionSerializer : NSObject

+ (instancetype)serializer;

- (NSDictionary *)dictionaryWithSubscription:(SKYSubscription *)subscription;

@end
