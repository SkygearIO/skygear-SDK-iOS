//
//  ODNotification.h
//  ;
//
//  Created by Kenji Pa on 29/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ODNotificationID.h"

@interface ODNotification : NSObject

+ (instancetype)notificationFromRemoteNotificationDictionary:(NSDictionary *)notificationDictionary;

@property (nonatomic, readonly, copy) ODNotificationID *notificationID;
@property (nonatomic, readonly, copy) NSString *containerIdentifier;

@property (nonatomic, readonly, assign) BOOL isPruned;

@property (nonatomic, readonly, copy) NSString *alertBody;
@property (nonatomic, readonly, copy) NSString *alertLocalizationKey;
@property (nonatomic, readonly, copy) NSArray *alertLocalizationArgs;
@property (nonatomic, readonly, copy) NSString *alertActionLocalizationKey;
@property (nonatomic, readonly, copy) NSString *alertLaunchImage;
@property (nonatomic, readonly, copy) NSString *soundName;
@property (nonatomic, readonly, copy) NSNumber *badge;

@end
