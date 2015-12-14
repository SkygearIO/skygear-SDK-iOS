//
//  SKYGCMNotificationInfo.m
//  SKYKit
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
//

#import "SKYGCMNotificationInfo.h"

static BOOL isNilOrEqualString(NSString *s1, NSString *s2)
{
    return (s1 == nil && s2 == nil) || [s1 isEqualToString:s2];
}

static BOOL isNilOrEqualArray(NSArray *a1, NSArray *a2)
{
    return (a1 == nil && a2 == nil) || [a1 isEqualToArray:a2];
}

@implementation SKYGCMInnerNotificationInfo

- (id)copyWithZone:(NSZone *)zone
{
    SKYGCMInnerNotificationInfo *info = [[self.class allocWithZone:zone] init];

    info->_title = [_title copyWithZone:zone];
    info->_body = [_body copyWithZone:zone];
    info->_icon = [_icon copyWithZone:zone];
    info->_sound = [_sound copyWithZone:zone];
    info->_tag = [_tag copyWithZone:zone];
    info->_clickAction = [_clickAction copyWithZone:zone];
    info->_bodyLocKey = [_bodyLocKey copyWithZone:zone];
    info->_bodyLocArgs = [_bodyLocArgs copyWithZone:zone];
    info->_titleLocKey = [_titleLocKey copyWithZone:zone];
    info->_titleLocArgs = [_titleLocArgs copyWithZone:zone];

    return info;
}

- (BOOL)isEqual:(id)object
{
    if (!object) {
        return NO;
    }

    if (![object isKindOfClass:SKYGCMInnerNotificationInfo.class]) {
        return NO;
    }

    return [self isEqualToNotificationInfo:object];
}

- (BOOL)isEqualToNotificationInfo:(SKYGCMInnerNotificationInfo *)n
{
    return isNilOrEqualString(self.title, n.title) && isNilOrEqualString(self.body, n.body) &&
           isNilOrEqualString(self.icon, n.icon) && isNilOrEqualString(self.sound, n.sound) &&
           isNilOrEqualString(self.tag, n.tag) &&
           isNilOrEqualString(self.clickAction, n.clickAction) &&
           isNilOrEqualString(self.bodyLocKey, n.bodyLocKey) &&
           isNilOrEqualArray(self.bodyLocArgs, n.bodyLocArgs) &&
           isNilOrEqualString(self.titleLocKey, n.titleLocKey) &&
           isNilOrEqualArray(self.titleLocArgs, n.titleLocArgs);
}

- (NSUInteger)hash
{
    return self.title.hash ^ self.body.hash ^ self.icon.hash ^ self.sound.hash ^ self.tag.hash ^
           self.clickAction.hash ^ self.bodyLocKey.hash ^ self.bodyLocArgs.hash ^
           self.titleLocKey.hash ^ self.titleLocArgs.hash;
}

- (NSString *)description
{
    return
        [NSString stringWithFormat:@"%@ <title = %@, body = %@, icon = %@, sound = %@, tag = %@, "
                                   @"clickAction = %@, bodyLocKey = %@, bodyLocArgs = %@, "
                                   @"titleLocKey = %@, titleLocArgs = %@>",
                                   NSStringFromClass(self.class), self.title, self.body, self.icon,
                                   self.sound, self.tag, self.clickAction, self.bodyLocKey,
                                   self.bodyLocArgs, self.titleLocKey, self.titleLocArgs];
}

@end

@implementation SKYGCMNotificationInfo

+ (instancetype)notificationInfo
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _notification = [[SKYGCMInnerNotificationInfo alloc] init];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    SKYGCMNotificationInfo *info = [[self.class allocWithZone:zone] init];

    info->_collapseKey = [_collapseKey copyWithZone:zone];
    info->_priority = _priority;
    info->_contentAvailable = _contentAvailable;
    info->_delayWhileIdle = _delayWhileIdle;
    info->_timeToLive = _timeToLive;
    info->_restrictedPackageName = [_restrictedPackageName copyWithZone:zone];
    info->_notification = [_notification copyWithZone:zone];

    return info;
}

- (BOOL)isEqual:(id)object
{
    if (!object) {
        return NO;
    }

    if (![object isKindOfClass:SKYGCMNotificationInfo.class]) {
        return NO;
    }

    return [self isEqualToNotificationInfo:object];
}

- (BOOL)isEqualToNotificationInfo:(SKYGCMNotificationInfo *)n
{
    return (isNilOrEqualString(self.collapseKey, n.collapseKey) && self.priority == n.priority &&
            self.contentAvailable == n.contentAvailable &&
            self.delayWhileIdle == n.delayWhileIdle && self.timeToLive == n.timeToLive &&
            isNilOrEqualString(self.restrictedPackageName, n.restrictedPackageName) &&
            ((self.notification == nil && n.notification == nil) ||
             [self.notification isEqual:n.notification]));
}

- (NSUInteger)hash
{
    return self.collapseKey.hash ^ self.priority ^ self.contentAvailable ^ self.delayWhileIdle ^
           self.timeToLive ^ self.restrictedPackageName.hash ^ self.notification.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ <collapseKey = %@, priority = %@, contentAvailable = "
                                      @"%@, delayWhileIdle = %@, timeToLive = %@, "
                                      @"restrictedPackageName = %@, notification = %@>",
                                      NSStringFromClass(self.class), self.collapseKey,
                                      @(self.priority), @(self.contentAvailable),
                                      @(self.delayWhileIdle), @(self.timeToLive),
                                      self.restrictedPackageName, self.notification];
}

@end
