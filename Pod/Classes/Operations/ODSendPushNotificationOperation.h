//
//  ODSendPushNotificationOperation.h
//  Pods
//
//  Created by atwork on 14/8/15.
//
//

#import <Foundation/Foundation.h>
#import "ODOperation.h"

@class ODNotificationInfo;

typedef enum : NSUInteger {
    ODPushTargetIsDevice,
    ODPushTargetIsUser,
} ODPushTarget;

@interface ODSendPushNotificationOperation : ODOperation

- (instancetype)initWithNotificationInfo:(ODNotificationInfo *)noteInfo
                              pushTarget:(ODPushTarget)pushTarget
                               IDsToSend:(NSArray *)IDsToSend;
+ (instancetype)operationWithNotificationInfo:(ODNotificationInfo *)noteInfo
                                userIDsToSend:(NSArray *)userIDsToSend;
+ (instancetype)operationWithNotificationInfo:(ODNotificationInfo *)noteInfo
                              deviceIDsToSend:(NSArray *)deviceIDsToSend;

@property (nonatomic, readwrite, copy) ODNotificationInfo *notificationInfo;
@property (nonatomic, readwrite) ODPushTarget pushTarget;
@property (nonatomic, readwrite, copy) NSArray *IDsToSend;
@property (nonatomic, copy) void (^perSendCompletionHandler)(NSString *userID, NSError *error);
@property (nonatomic, copy) void (^sendCompletionHandler)(NSArray *userIDs, NSError *error);


@end
