//
//  ODDeleteSubscriptionsOperation.m
//  Pods
//
//  Created by Kenji Pa on 21/4/15.
//
//

#import "ODDeleteSubscriptionsOperation.h"

@implementation ODDeleteSubscriptionsOperation

- (instancetype)initWithSubscriptionIDsToDelete:(NSArray *)subscriptionIDsToDelete
{
    self = [super init];
    if (self) {
        self.subscriptionIDsToDelete = subscriptionIDsToDelete;
    }
    return self;
}

@end
