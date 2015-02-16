//
//  ODSubscription.m
//  askq
//
//  Created by Kenji Pa on 29/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODSubscription.h"

@interface ODSubscription()

@property (nonatomic, copy) NSString *subscriptionID;

@end

@implementation ODSubscription

- (instancetype)initWithQuery:(ODQuery *)query {
    return [self initWithQuery:query subscriptionID:nil];
}

- (instancetype)initWithQuery:(ODQuery *)query
                 subscriptionID:(NSString *)subscriptionID {
    self = [super init];
    if (self) {
        _query = query;
        _subscriptionID = subscriptionID;
    }
    return self;
}

- (NSString *)subscriptionID {
    return @"someSubscriptionID";
}
@end
