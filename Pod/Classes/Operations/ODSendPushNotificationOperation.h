//
//  ODSendPushNotificationOperation.h
//  Pods
//
//  Created by atwork on 14/8/15.
//
//

#import <Foundation/Foundation.h>
#import "ODOperation.h"

typedef enum : NSUInteger {
    ODPushTargetIsDevice,
    ODPushTargetIsUser,
} ODPushTarget;

@interface ODSendPushNotificationOperation : ODOperation

- (instancetype)initWithNotificationPayload:(NSDictionary *)payload
                                 pushTarget:(ODPushTarget)pushTarget
                                  IDsToSend:(NSArray *)IDsToSend;
+ (instancetype)operationWithNotificationPayload:(NSDictionary *)payload
                                   userIDsToSend:(NSArray *)userIDsToSend;
+ (instancetype)operationWithNotificationPayload:(NSDictionary *)payload
                                 deviceIDsToSend:(NSArray *)deviceIDsToSend;

@property (nonatomic, readwrite, copy) NSDictionary *payload;
@property (nonatomic, readwrite) ODPushTarget pushTarget;
@property (nonatomic, readwrite, copy) NSArray *IDsToSend;
@property (nonatomic, copy) void (^perSendCompletionHandler)(NSString *userID, NSError *error);
@property (nonatomic, copy) void (^sendCompletionHandler)(NSArray *userIDs, NSError *error);


@end
