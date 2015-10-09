//
//  SKYDeleteSubscriptionsOperation.h
//  Pods
//
//  Created by Kenji Pa on 21/4/15.
//
//

#import "SKYDatabaseOperation.h"

@interface SKYDeleteSubscriptionsOperation : SKYDatabaseOperation

- (instancetype)initWithSubscriptionIDsToDelete:(NSArray *)subscriptionIDsToDelete;

+ (instancetype)operationWithSubscriptionIDsToDelete:(NSArray *)subscriptionIDsToDelete;

@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, copy) NSArray *subscriptionIDsToDelete;

@property (nonatomic, copy) void(^deleteSubscriptionsCompletionBlock)(NSArray *deletedSubscriptionIDs, NSError *operationError);

@end
