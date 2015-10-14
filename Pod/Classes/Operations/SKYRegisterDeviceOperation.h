//
//  SKYRegisterDeviceOperation.h
//  Pods
//
//  Created by atwork on 24/3/15.
//
//

#import <Foundation/Foundation.h>
#import "SKYOperation.h"

@interface SKYRegisterDeviceOperation : SKYOperation

- (instancetype)initWithDeviceToken:(NSData *)deviceToken;

/**
 Returns an instance of operation that registers a device without supplying a device token.

 You can use this method when a device token is not available because the user did not grant
 the permission for remote notification. Notification will arrive through the pubsub mechanism
 instead of remote notification.
 */
+ (instancetype)operation;
+ (instancetype)operationWithDeviceToken:(NSData *)deviceToken;

@property (nonatomic, readonly, copy) NSData *deviceToken;
@property (nonatomic, readwrite, copy) NSString *deviceID;
@property (nonatomic, copy) void (^registerCompletionBlock)(NSString *deviceID, NSError *error);

@end
