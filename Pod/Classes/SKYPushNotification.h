//
//  SKYPushNotification.h
//  askq
//
//  Created by Kenji Pa on 6/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYNotification.h"

#import "SKYUserRecordID.h"

/**
 `SKYPushNotification` is a concrete subclass of `SKYNotification` that represents a remote
 notification initiated by a `SKYPushOperation`.

 You do not create instances of this class directly. Instead, use `+[SKYNotification
 notificationFromRemoteNotificationDictionary:]` to reconstruct a `SKYPushNotification` from
 `notificationDictionary` you received from a remote notification.
  */
@interface SKYPushNotification : SKYNotification

+ (instancetype)notificationWithSenderID:(SKYUserRecordID *)userID;

/**
 The `SKYUserRecordID` of the sender who initiated this push notification. In Ourd, push
 notification is always sent by a user. This property will never be nil.
 */
@property (nonatomic, readonly, copy) SKYUserRecordID *senderRecordID;

@end
