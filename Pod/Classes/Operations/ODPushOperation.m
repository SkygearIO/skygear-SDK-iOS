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

+ (instancetype)operationWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertBody:(NSString *)alertBody
{
    return [[self alloc] initWithUserRecordIDs:userRecordIDs alertBody:alertBody];
}

+ (instancetype)operationWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertBody:(NSString *)alertBody alertActionLocalizationKey:(NSString *)alertActionLocalizationKey
{
    return [[self alloc] initWithUserRecordIDs:userRecordIDs alertBody:alertBody alertActionLocalizationKey:alertActionLocalizationKey];
}

+ (instancetype)operationWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertBody:(NSString *)alertBody alertActionLocalizationKey:(NSString *)alertActionLocalizationKey soundName:(NSString *)soundName
{
    return [[self alloc] initWithUserRecordIDs:userRecordIDs alertBody:alertBody alertActionLocalizationKey:alertActionLocalizationKey soundName:soundName];
}

+ (instancetype)operationWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertLocalizationKey:(NSString *)alertLocalizationKey alertLocalizationArgs:(NSArray *)alertLocalizationArgs
{
    return [[self alloc] initWithUserRecordIDs:userRecordIDs alertLocalizationKey:alertLocalizationKey alertLocalizationArgs:alertLocalizationArgs];
}

+ (instancetype)operationWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertLocalizationKey:(NSString *)alertLocalizationKey alertLocalizationArgs:(NSArray *)alertLocalizationArgs alertActionLocalizationKey:(NSString *)alertActionLocalizationKey
{
    return [[self alloc] initWithUserRecordIDs:userRecordIDs alertLocalizationKey:alertLocalizationKey alertLocalizationArgs:alertLocalizationArgs alertActionLocalizationKey:alertActionLocalizationKey];
}

+ (instancetype)operationWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs alertLocalizationKey:(NSString *)alertLocalizationKey alertLocalizationArgs:(NSArray *)alertLocalizationArgs alertActionLocalizationKey:(NSString *)alertActionLocalizationKey soundName:(NSString *)soundName
{
    return [[self alloc] initWithUserRecordIDs:userRecordIDs alertLocalizationKey:alertLocalizationKey alertLocalizationArgs:alertLocalizationArgs alertActionLocalizationKey:alertActionLocalizationKey soundName:soundName];
}

+ (instancetype)operationWithUserRecordID:(ODUserRecordID *)userRecordID notificationInfo:(ODNotificationInfo *)notificationInfo
{
    return [[self alloc] initWithUserRecordID:userRecordID notificationInfo:notificationInfo];
}

+ (instancetype)operationWithUserRecordIDs:(NSArray /* ODUserRecordID */ *)userRecordIDs notificationInfo:(ODNotificationInfo *)notificationInfo
{
    return [[self alloc] initWithUserRecordIDs:userRecordIDs notificationInfo:notificationInfo];
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
