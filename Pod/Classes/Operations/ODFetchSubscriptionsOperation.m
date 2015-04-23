//
//  ODFetchSubscriptionsOperation.m
//  askq
//
//  Created by Kenji Pa on 29/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODFetchSubscriptionsOperation.h"
#import "ODSubscriptionDeserializer.h"
#import "ODSubscriptionSerialization.h"

@interface ODFetchSubscriptionsOperation()

- (instancetype)initFetchAll NS_DESIGNATED_INITIALIZER;

@property (nonatomic, assign) BOOL isFetchAll;

@end

@implementation ODFetchSubscriptionsOperation

- (instancetype)initWithSubscriptionIDs:(NSArray *)subscriptionIDs
{
    self = [super init];
    if (self) {
        _subscriptionIDs = subscriptionIDs;
    }
    return self;
}

- (instancetype)initFetchAll
{
    self = [super init];
    if (self) {
        _isFetchAll = YES;
    }
    return self;
}

+ (instancetype)fetchAllSubscriptionsOperation
{
    return [[self alloc] initFetchAll];
}

- (void)prepareForRequest
{
    NSMutableArray *subscriptionIDs = [NSMutableArray array];
    for (NSString *subscription in self.subscriptionIDs) {
        [subscriptionIDs addObject:subscription];
    }
    NSMutableDictionary *payload = [@{
                                      @"database_id": self.database.databaseID,
                                      } mutableCopy];
    if (self.isFetchAll) {
        payload[@"fetch_all"] = @YES;
    } else if (subscriptionIDs.count) {
        payload[@"ids"] = subscriptionIDs;
    }
    self.request = [[ODRequest alloc] initWithAction:@"subscription:fetch"
                                             payload:payload];
    self.request.accessToken = self.container.currentAccessToken;
}

- (void)setFetchSubscriptionCompletionBlock:(void (^)(NSDictionary *subscriptionsBySubscriptionID, NSError *operationError))fetchSubscriptionCompletionBlock
{
    [self willChangeValueForKey:@"fetchSubscriptionCompletionBlock"];
    _fetchSubscriptionCompletionBlock = fetchSubscriptionCompletionBlock;
    [self updateCompletionBlock];
    [self didChangeValueForKey:@"fetchSubscriptionCompletionBlock"];
}

- (NSDictionary *)processResultArray:(NSArray *)result
{
    ODSubscriptionDeserializer* deserializer = [ODSubscriptionDeserializer deserializer];
    NSMutableDictionary *subscriptionsBySubscriptionID = [NSMutableDictionary dictionary];

    for (NSDictionary *dict in result) {
        ODSubscription *subscription = nil;
        NSString *subscriptionID = dict[ODSubscriptionSerializationSubscriptionIDKey];
        if (subscriptionID.length) {
            if ([self.subscriptionIDs containsObject:subscriptionID]) {
                NSLog(@"A returned subscription is not requested.");
            }

            NSString *subscriptionType = dict[ODSubscriptionSerializationSubscriptionTypeKey];
            if ([subscriptionType isEqual:ODSubscriptionSerializationSubscriptionTypeQuery]) {
                subscription = [deserializer subscriptionWithDictionary:dict];
            }
        }
        
        if (subscription) {
            subscriptionsBySubscriptionID[subscriptionID] = subscription;
        }
    }
    return subscriptionsBySubscriptionID;
}

- (void)updateCompletionBlock
{
    if (self.fetchSubscriptionCompletionBlock) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            NSDictionary *resultDictionary = nil;
            NSError *error = weakSelf.error;
            if (!error) {
                NSArray *responseArray = weakSelf.response[@"result"];
                if ([responseArray isKindOfClass:[NSArray class]]) {
                    resultDictionary = [weakSelf processResultArray:responseArray];
                } else {
                    NSDictionary *userInfo = [weakSelf errorUserInfoWithLocalizedDescription:@"Server returned malformed result."
                                                                             errorDictionary:nil];
                    error = [NSError errorWithDomain:(NSString *)ODOperationErrorDomain
                                                code:0
                                            userInfo:userInfo];
                }
            }

            if (weakSelf.fetchSubscriptionCompletionBlock) {
                weakSelf.fetchSubscriptionCompletionBlock(resultDictionary, error);
            }
        };
    } else {
        self.completionBlock = nil;
    }
}

@end
