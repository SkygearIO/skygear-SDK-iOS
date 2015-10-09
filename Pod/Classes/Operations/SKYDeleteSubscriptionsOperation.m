//
//  SKYDeleteSubscriptionsOperation.m
//  Pods
//
//  Created by Kenji Pa on 21/4/15.
//
//

#import "SKYDeleteSubscriptionsOperation.h"

#import "SKYDataSerialization.h"
#import "SKYDefaults.h"
#import "SKYError.h"
#import "SKYSubscription.h"

@implementation SKYDeleteSubscriptionsOperation

- (instancetype)initWithSubscriptionIDsToDelete:(NSArray *)subscriptionIDsToDelete
{
    self = [super init];
    if (self) {
        self.subscriptionIDsToDelete = subscriptionIDsToDelete;
    }
    return self;
}

+ (instancetype)operationWithSubscriptionIDsToDelete:(NSArray *)subscriptionIDsToDelete
{
    return [[self alloc] initWithSubscriptionIDsToDelete:subscriptionIDsToDelete];
}

- (void)prepareForRequest
{
    NSMutableDictionary *payload = [@{
                                       @"database_id": self.database.databaseID,
                                      } mutableCopy];


    NSString *deviceID = nil;
    if (self.deviceID) {
        deviceID = self.deviceID;
    } else {
        deviceID = [SKYDefaults sharedDefaults].deviceID;
    }
    if (deviceID.length) {
        payload[@"device_id"] = deviceID;
    }

    if (self.subscriptionIDsToDelete.count) {
        payload[@"ids"] = self.subscriptionIDsToDelete;
    }

    self.request = [[SKYRequest alloc] initWithAction:@"subscription:delete"
                                             payload:payload];
    self.request.APIKey = self.container.APIKey;
    self.request.accessToken = self.container.currentAccessToken;
}


- (void)processResultArray:(NSArray *)result deletedsubscriptionIDs:(NSArray **) deletedsubscriptionIDs operationError:(NSError **)operationError
{
    NSMutableArray *subscriptionIDs = [NSMutableArray array];
    NSMutableDictionary *errorBySubscriptionID = [NSMutableDictionary dictionary];

    [result enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSString *objType = obj[@"_type"];
        NSString *subscriptionID = obj[@"id"];
        if ([objType isEqual:@"error"]) {
            subscriptionID = obj[@"_id"];

            NSMutableDictionary *userInfo = [SKYDataSerialization userInfoWithErrorDictionary:obj];
            userInfo[NSLocalizedDescriptionKey] = @"An error occurred while deleting subscription.";
            errorBySubscriptionID[subscriptionID] = [NSError errorWithDomain:SKYOperationErrorDomain
                                                                        code:0
                                                                    userInfo:userInfo];
        } else if (subscriptionID.length) {
            [subscriptionIDs addObject:subscriptionID];
        } else {
            // malformed response
            NSMutableDictionary *userInfo = [self errorUserInfoWithLocalizedDescription:@"Missing `id` or not in correct format."
                                                                        errorDictionary:nil];
            errorBySubscriptionID[self.subscriptionIDsToDelete[idx]] = [NSError errorWithDomain:SKYOperationErrorDomain
                                                                                           code:0
                                                                                       userInfo:userInfo];

        }
    }];

    if (subscriptionIDs.count) {
        *deletedsubscriptionIDs = subscriptionIDs;
    }
    if (errorBySubscriptionID.count) {
        *operationError = [NSError errorWithDomain:SKYOperationErrorDomain
                                              code:SKYErrorPartialFailure
                                          userInfo:@{
                                                     SKYPartialErrorsByItemIDKey: errorBySubscriptionID,
                                                     }];
    }
}

- (void)handleRequestError:(NSError *)error
{
    if (self.deleteSubscriptionsCompletionBlock) {
        self.deleteSubscriptionsCompletionBlock(nil, error);
    }
}

- (void)handleResponse:(SKYResponse *)responseObject
{
    NSDictionary *response = responseObject.responseDictionary;
    if (self.deleteSubscriptionsCompletionBlock) {
        NSArray *deletedSubscriptions = nil;
        NSError *error = nil;
        NSArray *responseArray = response[@"result"];
        if ([responseArray isKindOfClass:[NSArray class]]) {
            [self processResultArray:responseArray deletedsubscriptionIDs:&deletedSubscriptions operationError:&error];
        } else {
            NSDictionary *userInfo = [self errorUserInfoWithLocalizedDescription:@"Server returned malformed result." errorDictionary:nil];
            error = [NSError errorWithDomain:SKYOperationErrorDomain
                                    code:0
                                userInfo:userInfo];
        }
        self.deleteSubscriptionsCompletionBlock(deletedSubscriptions, error);
    }
}

@end
