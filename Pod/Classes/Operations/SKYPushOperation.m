//
//  SKYPushOperation.m
//  SkyKit
//
//  Copyright 2015 Oursky Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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
