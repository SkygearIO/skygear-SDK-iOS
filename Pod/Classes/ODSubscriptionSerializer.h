//
//  ODSubscriptionSerializer.h
//  Pods
//
//  Created by Kenji Pa on 21/4/15.
//
//

#import <Foundation/Foundation.h>

#import "ODSubscription.h"

extern const NSString *ODSubscriptionSerializationTypeQuery;
extern const NSString *ODSubscriptionSerializationTypeRecordZone;

@interface ODSubscriptionSerializer : NSObject

+ (instancetype)serializer;

- (NSDictionary *)dictionaryWithSubscription:(ODSubscription *)subscription;

@end
