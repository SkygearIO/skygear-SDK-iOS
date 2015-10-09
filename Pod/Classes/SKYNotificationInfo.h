//
//  SKYNotificationInfo.h
//  askq
//
//  Created by Kenji Pa on 29/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKYNotificationInfo : NSObject<NSCopying>

+ (instancetype)notificationInfo;

@property(nonatomic, copy) NSString *alertBody;
@property(nonatomic, copy) NSString *alertLocalizationKey;
@property(nonatomic, copy) NSArray *alertLocalizationArgs;
@property(nonatomic, copy) NSString *alertActionLocalizationKey;
@property(nonatomic, copy) NSString *alertLaunchImage;
@property(nonatomic, copy) NSString *soundName;
@property(nonatomic, assign) BOOL shouldBadge;
@property(nonatomic, assign) BOOL shouldSendContentAvailable;

@property(nonatomic, copy) NSArray *desiredKeys;

- (BOOL)isEqualToNotificationInfo:(SKYNotificationInfo *)notificationInfo;

@end
