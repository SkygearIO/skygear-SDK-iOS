//
//  ODPushOperation.m
//  askq
//
//  Created by Kenji Pa on 26/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODPushOperation.h"

ODNotificationInfo *DefaultNotificationInfo;

@implementation ODPushOperation

+ (void)initialize {
    DefaultNotificationInfo = [[ODNotificationInfo alloc] init];
    DefaultNotificationInfo.shouldBadge = YES;
}

- (instancetype)initWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertBody:(NSString *)alertBody {
    return [self initWithUserRecordIDs:userRecordIDs alertBody:alertBody alertActionLocalizationKey:nil];
}

- (instancetype)initWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertBody:(NSString *)alertBody alertActionLocalizationKey:(NSString *)alertActionLocalizationKey {
    return [self initWithUserRecordIDs:userRecordIDs alertBody:alertBody alertActionLocalizationKey:alertActionLocalizationKey soundName:nil];
}

- (instancetype)initWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertBody:(NSString *)alertBody alertActionLocalizationKey:(NSString *)alertActionLocalizationKey soundName:(NSString *)soundName {
    ODNotificationInfo *info = [self.class defaultNotificationInfo];
    info.alertBody = alertBody;
    info.alertActionLocalizationKey = alertActionLocalizationKey;
    info.soundName = soundName;
    return [self initWithUserRecordIDs:userRecordIDs notificationInfo:info];
}

- (instancetype)initWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertLocalizationKey:(NSString *)alertLocalizationKey alertLocalizationArgs:(NSArray *)alertLocalizationArgs {
    return [self initWithUserRecordIDs:userRecordIDs alertLocalizationKey:alertLocalizationKey alertLocalizationArgs:alertLocalizationArgs alertActionLocalizationKey:nil];
}

- (instancetype)initWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertLocalizationKey:(NSString *)alertLocalizationKey alertLocalizationArgs:(NSArray *)alertLocalizationArgs alertActionLocalizationKey:(NSString *)alertActionLocalizationKey {
    return [self initWithUserRecordIDs:userRecordIDs alertLocalizationKey:alertLocalizationKey alertLocalizationArgs:alertLocalizationArgs alertActionLocalizationKey:alertActionLocalizationKey soundName:nil];
}

- (instancetype)initWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertLocalizationKey:(NSString *)alertLocalizationKey alertLocalizationArgs:(NSArray *)alertLocalizationArgs alertActionLocalizationKey:(NSString *)alertActionLocalizationKey soundName:(NSString *)soundName {
    ODNotificationInfo *info = [self.class defaultNotificationInfo];
    info.alertLocalizationKey = alertLocalizationKey;
    info.alertLocalizationArgs = alertLocalizationArgs;
    info.alertActionLocalizationKey = alertActionLocalizationKey;
    info.soundName = soundName;
    return [self initWithUserRecordIDs:userRecordIDs notificationInfo:info];
}

- (instancetype)initWithUserRecordID:(ODUserRecordID *)userRecordID notificationInfo:(ODNotificationInfo *)notificationInfo {
    return [self initWithUserRecordIDs:@[userRecordID] notificationInfo:notificationInfo];
}

- (instancetype)initWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs notificationInfo:(ODNotificationInfo *)notificationInfo {
    self = [super init];
    if (self) {
        _userRecordIDs = userRecordIDs;
        _notificationInfo = notificationInfo;
    }
    return self;
}

+ (ODNotificationInfo *)defaultNotificationInfo {
    return [DefaultNotificationInfo copy];
}

- (BOOL)isAsynchronous
{
    return NO;
}

- (void)main {
    // do nothing
}

@end
