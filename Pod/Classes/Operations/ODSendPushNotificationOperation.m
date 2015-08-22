//
//  ODSendPushNotificationOperation.m
//  Pods
//
//  Created by atwork on 14/8/15.
//
//

#import "ODSendPushNotificationOperation.h"
#import "ODRequest.h"
#import "ODRecordSerialization.h"
#import "ODDataSerialization.h"
#import "ODError.h"
#import "ODResultArrayResponse.h"
#import "ODNotificationInfo.h"
#import "ODNotificationInfoSerializer.h"

@implementation ODSendPushNotificationOperation

- (instancetype)initWithNotificationInfo:(ODNotificationInfo *)notificationInfo pushTarget:(ODPushTarget)pushTarget IDsToSend:(NSArray *)IDsToSend
{
    self = [super init];
    if (self) {
        _notificationInfo = [notificationInfo copy];
        _IDsToSend = [IDsToSend copy];
        _pushTarget = pushTarget;
        
        [_IDsToSend enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (![obj isKindOfClass:[NSString class]]) {
                NSString *reason = [NSString stringWithFormat:@"User ID must be NSString. Got %@", NSStringFromClass([obj class])];
                @throw [NSException exceptionWithName:NSInvalidArgumentException
                                               reason:reason
                                             userInfo:nil];
            }
        }];
    }
    return self;
}

+ (instancetype)operationWithNotificationInfo:(ODNotificationInfo *)noteInfo userIDsToSend:(NSArray *)userIDsToSend
{
    return [[self alloc] initWithNotificationInfo:noteInfo
                                       pushTarget:ODPushTargetIsUser
                                        IDsToSend:userIDsToSend];
}

+ (instancetype)operationWithNotificationInfo:(ODNotificationInfo *)noteInfo deviceIDsToSend:(NSArray *)deviceIDsToSend
{
    return [[self alloc] initWithNotificationInfo:noteInfo
                                       pushTarget:ODPushTargetIsDevice
                                        IDsToSend:deviceIDsToSend];
}

+ (Class)responseClass
{
    return [ODResultArrayResponse class];
}

- (void)prepareForRequest
{
    NSString *action;
    NSMutableDictionary *payload;
    
    ODNotificationInfoSerializer *serializer = [ODNotificationInfoSerializer serializer];
    NSDictionary *serializedNotification = [serializer dictionaryWithNotificationInfo:self.notificationInfo];

    switch (self.pushTarget) {
        case ODPushTargetIsUser:
            action = @"push:user";
            payload = [@{
                         @"user_ids": self.IDsToSend,
                         @"notification": serializedNotification,
                         } mutableCopy];
            break;
        case ODPushTargetIsDevice:
            action = @"push:device";
            payload = [@{
                         @"device_ids": self.IDsToSend,
                         @"notification": serializedNotification,
                         } mutableCopy];
            break;
        default: {
            NSString *reason = [NSString stringWithFormat:@"unexpected push target %d", (int)self.pushTarget];
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:reason
                                         userInfo:nil];
        }
    }
    self.request = [[ODRequest alloc] initWithAction:action
                                             payload:payload];
    self.request.APIKey = self.container.APIKey;
}

- (void)handleRequestError:(NSError *)error
{
    if (self.sendCompletionHandler) {
        self.sendCompletionHandler(nil, error);
    }
}

- (void)handleResponse:(ODResultArrayResponse *)response
{
    NSMutableArray *successIDs = nil;
    NSError *error = nil;
    if (response.error) {
        error = response.error;
    } else {
        successIDs = [NSMutableArray array];
        NSMutableDictionary *errorsByID = [NSMutableDictionary dictionary];
        [response enumerateResultsUsingBlock:^(NSString *resultKey, NSDictionary *result, NSError *error, NSUInteger idx, BOOL *stop) {
            
            if (error && resultKey) {
                errorsByID[resultKey] = error;
            } else {
                [successIDs addObject:resultKey];
            }
            if (self.perSendCompletionHandler) {
                self.perSendCompletionHandler(resultKey, error);
            }
        }];
        
        if ([errorsByID count] > 0) {
            NSDictionary *errorUserInfo = @{
                                            ODPartialErrorsByItemIDKey: errorsByID,
                                            };
            error = [NSError errorWithDomain:ODOperationErrorDomain
                                        code:ODErrorPartialFailure
                                    userInfo:errorUserInfo];
        }
    }
    
    if (self.sendCompletionHandler) {
        self.sendCompletionHandler(successIDs, error);
    }
}

@end
