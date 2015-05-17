//
//  ODModifySubscriptionsOperation.h
//  askq
//
//  Created by Kenji Pa on 29/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODDatabaseOperation.h"
#import "ODSubscription.h"

@interface ODModifySubscriptionsOperation : ODDatabaseOperation

- (instancetype)initWithSubscriptionsToSave:(NSArray *)subscriptionsToSave;

@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, copy) NSArray *subscriptionsToSave;

@property (nonatomic, copy) void(^modifySubscriptionsCompletionBlock)(NSArray *savedSubscriptions, NSError *operationError);

@end
