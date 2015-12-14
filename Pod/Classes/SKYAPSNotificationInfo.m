//
//  SKYAPSNotificationInfo.m
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

#import "SKYAPSNotificationInfo.h"

static BOOL isNilOrEqualString(NSString *s1, NSString *s2)
{
    return (s1 == nil && s2 == nil) || [s1 isEqualToString:s2];
}

static BOOL isNilOrEqualArray(NSArray *a1, NSArray *a2)
{
    return (a1 == nil && a2 == nil) || [a1 isEqualToArray:a2];
}

@implementation SKYAPSNotificationInfo

+ (instancetype)notificationInfo
{
    return [[self alloc] init];
}

- (id)copyWithZone:(NSZone *)zone
{
    SKYAPSNotificationInfo *info = [[self.class allocWithZone:zone] init];

    info->_alertBody = [_alertBody copyWithZone:zone];
    info->_alertLocalizationKey = [_alertLocalizationKey copyWithZone:zone];
    info->_alertLocalizationArgs = [_alertLocalizationArgs copyWithZone:zone];
    info->_alertActionLocalizationKey = [_alertActionLocalizationKey copyWithZone:zone];
    info->_alertLaunchImage = [_alertLaunchImage copyWithZone:zone];
    info->_soundName = [_soundName copyWithZone:zone];
    info->_shouldBadge = _shouldBadge;
    info->_shouldSendContentAvailable = _shouldSendContentAvailable;

    return info;
}

- (BOOL)isEqual:(id)object
{
    if (!object) {
        return NO;
    }

    if (![object isKindOfClass:SKYAPSNotificationInfo.class]) {
        return NO;
    }

    return [self isEqualToNotificationInfo:object];
}

- (BOOL)isEqualToNotificationInfo:(SKYAPSNotificationInfo *)n
{
    return isNilOrEqualString(self.alertActionLocalizationKey, n.alertActionLocalizationKey) &&
           isNilOrEqualString(self.alertBody, n.alertBody) &&
           isNilOrEqualString(self.alertLaunchImage, self.alertLaunchImage) &&
           isNilOrEqualArray(self.alertLocalizationArgs, n.alertLocalizationArgs) &&
           isNilOrEqualString(self.alertLocalizationKey, n.alertLocalizationKey) &&
           isNilOrEqualString(self.soundName, n.soundName) && self.shouldBadge == n.shouldBadge &&
           self.shouldSendContentAvailable == n.shouldSendContentAvailable;
}

- (NSUInteger)hash
{
    return self.alertActionLocalizationKey.hash ^ self.alertBody.hash ^ self.alertLaunchImage.hash ^
           self.alertLocalizationArgs.hash ^ self.alertLocalizationKey.hash ^ self.soundName.hash ^
           self.shouldBadge ^ self.shouldSendContentAvailable;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ <alertBody = %@, alertLocalizationKey = %@, "
                                      @"alertLocalizationArgs = %@, alertActionLocalizationKey = "
                                      @"%@, alertLaunchImage = %@, soundName = %@, shouldBadge = "
                                      @"%@, shouldSendContentAvailable = %@>",
                                      NSStringFromClass(self.class), self.alertBody,
                                      self.alertLocalizationKey, self.alertLocalizationArgs,
                                      self.alertActionLocalizationKey, self.alertLaunchImage,
                                      self.soundName, @(self.shouldBadge),
                                      @(self.shouldSendContentAvailable)];
}

@end
