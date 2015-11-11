//
//  SKYFetchSubscriptionsOperation.h
//  askq
//
//  Created by Kenji Pa on 29/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYDatabaseOperation.h"

@interface SKYFetchSubscriptionsOperation : SKYDatabaseOperation

- (instancetype)initWithSubscriptionIDs:(NSArray *)subscriptionIDs NS_DESIGNATED_INITIALIZER;

+ (instancetype)fetchAllSubscriptionsOperation;
+ (instancetype)operationWithSubscriptionIDs:(NSArray *)subscriptionIDs;

@property (nonatomic, copy) NSString *deviceID;

@property (nonatomic, copy) NSArray *subscriptionIDs;

@property (nonatomic, copy) void (^fetchSubscriptionCompletionBlock)
    (NSDictionary *subscriptionsBySubscriptionID, NSError *operationError);

@end
