//
//  ODModifySubscriptionsOperation.m
//  askq
//
//  Created by Kenji Pa on 29/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODModifySubscriptionsOperation.h"

#import "ODDefaults.h"
#import "ODSubscriptionSerialization.h"
#import "ODSubscriptionSerializer.h"
#import "ODDataSerialization.h"

@implementation ODModifySubscriptionsOperation {
    NSMutableDictionary *subscriptionsByID;
}

- (instancetype)initWithSubscriptionsToSave:(NSArray *)subscriptionsToSave
{
    self = [super init];
    if (self) {
        self.subscriptionsToSave = subscriptionsToSave;
    }
    return self;
}

+ (instancetype)operationWithSubscriptionsToSave:(NSArray *)subscriptionsToSave;
{
    return [[self alloc] initWithSubscriptionsToSave:subscriptionsToSave];
}

- (void)prepareForRequest
{
    ODSubscriptionSerializer *serializer = [ODSubscriptionSerializer serializer];

    NSMutableDictionary *payload = [@{
                                      @"database_id": self.database.databaseID,
                                      } mutableCopy];

    NSMutableArray *dictionariesToSave = [NSMutableArray array];
    subscriptionsByID = [NSMutableDictionary dictionary];
    for (ODSubscription *subscription in self.subscriptionsToSave) {
        [dictionariesToSave addObject:[serializer dictionaryWithSubscription:subscription]];
        subscriptionsByID[subscription.subscriptionID] = subscription;
    }
    if (dictionariesToSave.count) {
        payload[@"subscriptions"] = dictionariesToSave;
    }

    NSString *deviceID = nil;
    if (self.deviceID) {
        deviceID = self.deviceID;
    } else {
        deviceID = [ODDefaults sharedDefaults].deviceID;
    }
    if (deviceID.length) {
        payload[@"device_id"] = deviceID;
    }

    self.request = [[ODRequest alloc] initWithAction:@"subscription:save"
                                             payload:payload];
    self.request.APIKey = self.container.APIKey;
    self.request.accessToken = self.container.currentAccessToken;
}

- (void)setModifySubscriptionsCompletionBlock:(void (^)(NSArray *, NSError *))modifySubscriptionsCompletionBlock
{
    [self willChangeValueForKey:@"modifySubscriptionsCompletionBlock"];
    _modifySubscriptionsCompletionBlock = modifySubscriptionsCompletionBlock;
    [self updateCompletionBlock];
    [self didChangeValueForKey:@"modifySubscriptionsCompletionBlock"];
}

- (NSArray *)processResultArray:(NSArray *)result
{
    NSMutableArray *savedSubscriptions = [NSMutableArray array];
    for (NSDictionary *dict in result) {
        // per item error has not been utilized yet
//        NSError *error = nil;
        ODSubscription *subscription = nil;
        NSString *subscriptionID = dict[ODSubscriptionSerializationSubscriptionIDKey];
        if (subscriptionID) {
            subscription = subscriptionsByID[subscriptionID];
            if (!subscription) {
                NSLog(@"A returned subscription is not requested.");
            }

            NSString *subscriptionType = dict[ODSubscriptionSerializationSubscriptionTypeKey];
            if ([subscriptionType isEqual:ODSubscriptionSerializationSubscriptionTypeQuery]) {
                // do nothing
            } else if ([subscriptionType isEqual:ODSubscriptionSerializationSubscriptionTypeError]) {
//                NSMutableDictionary *userInfo = [ODDataSerialization userInfoWithErrorDictionary:dict];
//                userInfo[NSLocalizedDescriptionKey] = @"An error occurred while modifying subscription.";
//                error = [NSError errorWithDomain:(NSString *)ODOperationErrorDomain
//                                            code:0
//                                        userInfo:userInfo];
            }
        } else {
//            NSMutableDictionary *userInfo = [self errorUserInfoWithLocalizedDescription:@"Missing `id`"
//                                                                        errorDictionary:nil];
//            error = [NSError errorWithDomain:(NSString *)ODOperationErrorDomain
//                                        code:0
//                                    userInfo:userInfo];
        }

        if (subscription) {
            [savedSubscriptions addObject:subscription];
        }
    }

    return savedSubscriptions;
}

- (void)updateCompletionBlock
{
    if (self.modifySubscriptionsCompletionBlock) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            NSArray *resultArray = nil;
            NSError *error = weakSelf.error;
            if (!error) {
                NSArray *responseArray = weakSelf.response[@"result"];
                if ([responseArray isKindOfClass:[NSArray class]]) {
                    resultArray = [weakSelf processResultArray:responseArray];
                } else {
                    NSDictionary *userInfo = [weakSelf errorUserInfoWithLocalizedDescription:@"Server returned malformed results."
                                                                             errorDictionary:nil];
                    error = [NSError errorWithDomain:(NSString *)ODOperationErrorDomain
                                                code:0
                                            userInfo:userInfo];
                }
            }

            if (weakSelf.modifySubscriptionsCompletionBlock) {
                weakSelf.modifySubscriptionsCompletionBlock(resultArray, error);
            }
        };
    } else {
        self.completionBlock = nil;
    }
}

@end
