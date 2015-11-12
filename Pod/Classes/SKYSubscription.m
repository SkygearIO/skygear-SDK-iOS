//
//  SKYSubscription.m
//  askq
//
//  Created by Kenji Pa on 29/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYSubscription.h"

@interface SKYSubscription ()

@property (nonatomic, copy) NSString *subscriptionID;
@property (nonatomic, readwrite, assign) SKYSubscriptionType subscriptionType;

@end

@implementation SKYSubscription

- (instancetype)initWithQuery:(SKYQuery *)query
{
    return [self initWithQuery:query subscriptionID:nil];
}

- (instancetype)initWithQuery:(SKYQuery *)query subscriptionID:(NSString *)subscriptionID
{
    self = [super init];
    if (self) {
        _subscriptionType = SKYSubscriptionTypeQuery;
        _query = query;
        _subscriptionID = subscriptionID;
    }
    return self;
}

+ (instancetype)subscriptionWithQuery:(SKYQuery *)query
{
    return [[self alloc] initWithQuery:query];
}

+ (instancetype)subscriptionWithQuery:(SKYQuery *)query subscriptionID:(NSString *)subscriptionID
{
    return [[self alloc] initWithQuery:query subscriptionID:subscriptionID];
}

@end
