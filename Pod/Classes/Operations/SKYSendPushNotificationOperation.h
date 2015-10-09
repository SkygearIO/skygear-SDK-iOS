//
//  SKYSendPushNotificationOperation.h
//  Pods
//
//  Created by atwork on 14/8/15.
//
//

#import <Foundation/Foundation.h>
#import "SKYOperation.h"

@class SKYNotificationInfo;

typedef enum : NSUInteger {
    SKYPushTargetIsDevice,
    SKYPushTargetIsUser,
} SKYPushTarget;

@interface SKYSendPushNotificationOperation : SKYOperation

- (instancetype)initWithNotificationInfo:(SKYNotificationInfo *)noteInfo
                              pushTarget:(SKYPushTarget)pushTarget
                               IDsToSend:(NSArray *)IDsToSend;
+ (instancetype)operationWithNotificationInfo:(SKYNotificationInfo *)noteInfo
                                userIDsToSend:(NSArray *)userIDsToSend;
+ (instancetype)operationWithNotificationInfo:(SKYNotificationInfo *)noteInfo
                              deviceIDsToSend:(NSArray *)deviceIDsToSend;

@property (nonatomic, readwrite, copy) SKYNotificationInfo *notificationInfo;
@property (nonatomic, readwrite) SKYPushTarget pushTarget;
@property (nonatomic, readwrite, copy) NSArray *IDsToSend;
@property (nonatomic, copy) void (^perSendCompletionHandler)(NSString *userID, NSError *error);
@property (nonatomic, copy) void (^sendCompletionHandler)(NSArray *userIDs, NSError *error);


@end
