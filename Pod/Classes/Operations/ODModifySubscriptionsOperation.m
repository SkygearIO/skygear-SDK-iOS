//
//  ODModifySubscriptionsOperation.m
//  askq
//
//  Created by Kenji Pa on 29/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODModifySubscriptionsOperation.h"

@implementation ODModifySubscriptionsOperation

- (instancetype)initWithSubscriptionsToSave:(NSArray *)subscriptionsToSave
{
    self = [super init];
    if (self) {
        self.subscriptionsToSave = subscriptionsToSave;
    }
    return self;
}

@end
