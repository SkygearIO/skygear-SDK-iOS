//
//  SKYSubscription.h
//  askq
//
//  Created by Kenji Pa on 29/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SKYNotificationInfo.h"
#import "SKYQuery.h"

typedef enum : NSInteger {
    SKYSubscriptionTypeQuery      = 1,
    SKYSubscriptionTypeRecordZone = 2,
} SKYSubscriptionType;

@interface SKYSubscription : NSObject

- (instancetype)initWithQuery:(SKYQuery *)query;
- (instancetype)initWithQuery:(SKYQuery *)query
                 subscriptionID:(NSString *)subscriptionID;

+ (instancetype)subscriptionWithQuery:(SKYQuery *)query;
+ (instancetype)subscriptionWithQuery:(SKYQuery *)query
                       subscriptionID:(NSString *)subscriptionID;

@property (nonatomic, readonly, assign) SKYSubscriptionType subscriptionType;

@property (nonatomic, readonly) SKYQuery *query;

// probably duplicated with query?
@property (nonatomic, readonly, copy) NSString *recordType;
@property (nonatomic, readonly, copy) NSPredicate *predicate;

@property(nonatomic, copy) SKYNotificationInfo *notificationInfo;

@property (nonatomic, readonly, copy) NSString *subscriptionID;

@end
