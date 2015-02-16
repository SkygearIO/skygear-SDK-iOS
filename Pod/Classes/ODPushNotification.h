//
//  ODPushNotification.h
//  askq
//
//  Created by Kenji Pa on 6/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODNotification.h"

#import "ODUserRecordID.h"

/**
 `ODPushNotification` is a concrete subclass of `ODNotification` that represents a remote notification initiated by a `ODPushOperation`.
 
 You do not create instances of this class directly. Instead, use `+[ODNotification notificationFromRemoteNotificationDictionary:]` to reconstruct a `ODPushNotification` from `notificationDictionary` you received from a remote notification.
  */
@interface ODPushNotification : ODNotification

/**
 The `ODUserRecordID` of the sender who initiated this push notification. In Ourd, push notification is always sent by a user. This property will never be nil.
 */
@property (nonatomic, readonly, copy) ODUserRecordID *senderRecordID;

@end
