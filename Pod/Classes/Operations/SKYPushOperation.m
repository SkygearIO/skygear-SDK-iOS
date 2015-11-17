//
//  SKYPushOperation.m
//  askq
//
//  Created by Kenji Pa on 26/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYPushOperation.h"

SKYNotificationInfo *DefaultNotificationInfo;

@implementation SKYPushOperation

+ (void)initialize
{
    DefaultNotificationInfo = [[SKYNotificationInfo alloc] init];
    DefaultNotificationInfo.apsNotificationInfo = [SKYAPSNotificationInfo notificationInfo];
    DefaultNotificationInfo.apsNotificationInfo.shouldBadge = YES;
}

- (instancetype)initWithUserRecordIDs:(NSArray /* SKYUserRecordID */ *)userRecordIDs
                            alertBody:(NSString *)alertBody
{
    return [self initWithUserRecordIDs:userRecordIDs
                             alertBody:alertBody
            alertActionLocalizationKey:nil];
}

- (instancetype)initWithUserRecordIDs:(NSArray /* SKYUserRecordID */ *)userRecordIDs
                            alertBody:(NSString *)alertBody
           alertActionLocalizationKey:(NSString *)alertActionLocalizationKey
{
    return [self initWithUserRecordIDs:userRecordIDs
                             alertBody:alertBody
            alertActionLocalizationKey:alertActionLocalizationKey
                             soundName:nil];
}

- (instancetype)initWithUserRecordIDs:(NSArray /* SKYUserRecordID */ *)userRecordIDs
                            alertBody:(NSString *)alertBody
           alertActionLocalizationKey:(NSString *)alertActionLocalizationKey
                            soundName:(NSString *)soundName
{
    SKYNotificationInfo *info = [self.class defaultNotificationInfo];
    info.apsNotificationInfo.alertBody = alertBody;
    info.apsNotificationInfo.alertActionLocalizationKey = alertActionLocalizationKey;
    info.apsNotificationInfo.soundName = soundName;
    return [self initWithUserRecordIDs:userRecordIDs notificationInfo:info];
}

- (instancetype)initWithUserRecordIDs:(NSArray /* SKYUserRecordID */ *)userRecordIDs
                 alertLocalizationKey:(NSString *)alertLocalizationKey
                alertLocalizationArgs:(NSArray *)alertLocalizationArgs
{
    return [self initWithUserRecordIDs:userRecordIDs
                  alertLocalizationKey:alertLocalizationKey
                 alertLocalizationArgs:alertLocalizationArgs
            alertActionLocalizationKey:nil];
}

- (instancetype)initWithUserRecordIDs:(NSArray /* SKYUserRecordID */ *)userRecordIDs
                 alertLocalizationKey:(NSString *)alertLocalizationKey
                alertLocalizationArgs:(NSArray *)alertLocalizationArgs
           alertActionLocalizationKey:(NSString *)alertActionLocalizationKey
{
    return [self initWithUserRecordIDs:userRecordIDs
                  alertLocalizationKey:alertLocalizationKey
                 alertLocalizationArgs:alertLocalizationArgs
            alertActionLocalizationKey:alertActionLocalizationKey
                             soundName:nil];
}

- (instancetype)initWithUserRecordIDs:(NSArray /* SKYUserRecordID */ *)userRecordIDs
                 alertLocalizationKey:(NSString *)alertLocalizationKey
                alertLocalizationArgs:(NSArray *)alertLocalizationArgs
           alertActionLocalizationKey:(NSString *)alertActionLocalizationKey
                            soundName:(NSString *)soundName
{
    SKYNotificationInfo *info = [self.class defaultNotificationInfo];
    info.apsNotificationInfo.alertLocalizationKey = alertLocalizationKey;
    info.apsNotificationInfo.alertLocalizationArgs = alertLocalizationArgs;
    info.apsNotificationInfo.alertActionLocalizationKey = alertActionLocalizationKey;
    info.apsNotificationInfo.soundName = soundName;
    return [self initWithUserRecordIDs:userRecordIDs notificationInfo:info];
}

- (instancetype)initWithUserRecordID:(SKYUserRecordID *)userRecordID
                    notificationInfo:(SKYNotificationInfo *)notificationInfo
{
    return [self initWithUserRecordIDs:@[ userRecordID ] notificationInfo:notificationInfo];
}

- (instancetype)initWithUserRecordIDs:(NSArray /* SKYUserRecordID */ *)userRecordIDs
                     notificationInfo:(SKYNotificationInfo *)notificationInfo
{
    self = [super init];
    if (self) {
        _userRecordIDs = userRecordIDs;
        _notificationInfo = notificationInfo;
    }
    return self;
}

+ (instancetype)operationWithUserRecordIDs:(NSArray /* SKYUserRecordID */ *)userRecordIDs
                                 alertBody:(NSString *)alertBody
{
    return [[self alloc] initWithUserRecordIDs:userRecordIDs alertBody:alertBody];
}

+ (instancetype)operationWithUserRecordIDs:(NSArray /* SKYUserRecordID */ *)userRecordIDs
                                 alertBody:(NSString *)alertBody
                alertActionLocalizationKey:(NSString *)alertActionLocalizationKey
{
    return [[self alloc] initWithUserRecordIDs:userRecordIDs
                                     alertBody:alertBody
                    alertActionLocalizationKey:alertActionLocalizationKey];
}

+ (instancetype)operationWithUserRecordIDs:(NSArray /* SKYUserRecordID */ *)userRecordIDs
                                 alertBody:(NSString *)alertBody
                alertActionLocalizationKey:(NSString *)alertActionLocalizationKey
                                 soundName:(NSString *)soundName
{
    return [[self alloc] initWithUserRecordIDs:userRecordIDs
                                     alertBody:alertBody
                    alertActionLocalizationKey:alertActionLocalizationKey
                                     soundName:soundName];
}

+ (instancetype)operationWithUserRecordIDs:(NSArray /* SKYUserRecordID */ *)userRecordIDs
                      alertLocalizationKey:(NSString *)alertLocalizationKey
                     alertLocalizationArgs:(NSArray *)alertLocalizationArgs
{
    return [[self alloc] initWithUserRecordIDs:userRecordIDs
                          alertLocalizationKey:alertLocalizationKey
                         alertLocalizationArgs:alertLocalizationArgs];
}

+ (instancetype)operationWithUserRecordIDs:(NSArray /* SKYUserRecordID */ *)userRecordIDs
                      alertLocalizationKey:(NSString *)alertLocalizationKey
                     alertLocalizationArgs:(NSArray *)alertLocalizationArgs
                alertActionLocalizationKey:(NSString *)alertActionLocalizationKey
{
    return [[self alloc] initWithUserRecordIDs:userRecordIDs
                          alertLocalizationKey:alertLocalizationKey
                         alertLocalizationArgs:alertLocalizationArgs
                    alertActionLocalizationKey:alertActionLocalizationKey];
}

+ (instancetype)operationWithUserRecordIDs:(NSArray /* SKYUserRecordID */ *)userRecordIDs
                      alertLocalizationKey:(NSString *)alertLocalizationKey
                     alertLocalizationArgs:(NSArray *)alertLocalizationArgs
                alertActionLocalizationKey:(NSString *)alertActionLocalizationKey
                                 soundName:(NSString *)soundName
{
    return [[self alloc] initWithUserRecordIDs:userRecordIDs
                          alertLocalizationKey:alertLocalizationKey
                         alertLocalizationArgs:alertLocalizationArgs
                    alertActionLocalizationKey:alertActionLocalizationKey
                                     soundName:soundName];
}

+ (instancetype)operationWithUserRecordID:(SKYUserRecordID *)userRecordID
                         notificationInfo:(SKYNotificationInfo *)notificationInfo
{
    return [[self alloc] initWithUserRecordID:userRecordID notificationInfo:notificationInfo];
}

+ (instancetype)operationWithUserRecordIDs:(NSArray /* SKYUserRecordID */ *)userRecordIDs
                          notificationInfo:(SKYNotificationInfo *)notificationInfo
{
    return [[self alloc] initWithUserRecordIDs:userRecordIDs notificationInfo:notificationInfo];
}

+ (SKYNotificationInfo *)defaultNotificationInfo
{
    return [DefaultNotificationInfo copy];
}

- (BOOL)isAsynchronous
{
    return NO;
}

- (void)main
{
    // do nothing
}

@end
