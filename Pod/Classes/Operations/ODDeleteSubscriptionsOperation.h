//
//  ODDeleteSubscriptionsOperation.h
//  Pods
//
//  Created by Kenji Pa on 21/4/15.
//
//

#import "ODDatabaseOperation.h"

@interface ODDeleteSubscriptionsOperation : ODDatabaseOperation

- (instancetype)initWithSubscriptionIDsToDelete:(NSArray *)subscriptionIDsToDelete;

@property (nonatomic, copy) NSArray *subscriptionIDsToDelete;

@property (nonatomic, copy) void(^deleteSubscriptionsCompletionBlock)(NSArray *deletedSubscriptionIDs, NSError *operationError);

@end
