//
//  SKYModifySubscriptionsOperation.h
//  askq
//
//  Created by Kenji Pa on 29/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYDatabaseOperation.h"
#import "SKYSubscription.h"

@interface SKYModifySubscriptionsOperation : SKYDatabaseOperation

- (instancetype)initWithSubscriptionsToSave:(NSArray *)subscriptionsToSave;

+ (instancetype)operationWithSubscriptionsToSave:(NSArray *)subscriptionsToSave;

@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, copy) NSArray *subscriptionsToSave;

@property (nonatomic, copy) void (^modifySubscriptionsCompletionBlock)
    (NSArray *savedSubscriptions, NSError *operationError);

@end
