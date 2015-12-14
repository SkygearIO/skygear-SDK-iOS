//
//  SKYNotificationInfo.m
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

#import "SKYNotificationInfo.h"

static BOOL isNilOrEqualArray(NSArray *a1, NSArray *a2)
{
    return (a1 == nil && a2 == nil) || [a1 isEqualToArray:a2];
}

@implementation SKYNotificationInfo

+ (instancetype)notificationInfo
{
    return [[self alloc] init];
}

- (id)copyWithZone:(NSZone *)zone
{
    SKYNotificationInfo *info = [[self.class allocWithZone:zone] init];

    info->_apsNotificationInfo = [_apsNotificationInfo copyWithZone:zone];
    info->_gcmNotificationInfo = [_gcmNotificationInfo copyWithZone:zone];
    info->_desiredKeys = [_desiredKeys copyWithZone:zone];

    return info;
}

- (BOOL)isEqual:(id)object
{
    if (!object) {
        return NO;
    }

    if (![object isKindOfClass:SKYNotificationInfo.class]) {
        return NO;
    }

    return [self isEqualToNotificationInfo:object];
}

- (BOOL)isEqualToNotificationInfo:(SKYNotificationInfo *)n
{
    return (((self.apsNotificationInfo == nil && n.apsNotificationInfo == nil) ||
             [self.apsNotificationInfo isEqualToNotificationInfo:n.apsNotificationInfo]) &&
            ((self.gcmNotificationInfo == nil && n.gcmNotificationInfo == nil) ||
             [self.gcmNotificationInfo isEqualToNotificationInfo:n.gcmNotificationInfo]) &&
            isNilOrEqualArray(self.desiredKeys, n.desiredKeys));
}

- (NSUInteger)hash
{
    return self.apsNotificationInfo.hash ^ self.gcmNotificationInfo.hash ^ self.desiredKeys.hash;
}

- (NSString *)description
{
    return
        [NSString stringWithFormat:
                      @"%@ <apsNotificationInfo = %@, gcmNotificationInfo = %@, desiredKeys = %@>",
                      NSStringFromClass(self.class), self.apsNotificationInfo,
                      self.gcmNotificationInfo, self.desiredKeys];
}

@end
