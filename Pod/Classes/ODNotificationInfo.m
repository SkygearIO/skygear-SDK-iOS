//
//  ODNotificationInfo.m
//  askq
//
//  Created by Kenji Pa on 29/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODNotificationInfo.h"

@implementation ODNotificationInfo

- (id)copyWithZone:(NSZone *)zone {
    ODNotificationInfo *info = [[self.class allocWithZone:zone] init];

    info->_alertBody = [_alertBody copyWithZone:zone];
    info->_alertLocalizationKey = [_alertLocalizationKey copyWithZone:zone];
    info->_alertLocalizationArgs = [_alertLocalizationArgs copyWithZone:zone];
    info->_alertActionLocalizationKey = [_alertActionLocalizationKey copyWithZone:zone];
    info->_alertLaunchImage = [_alertLaunchImage copyWithZone:zone];
    info->_soundName = [_soundName copyWithZone:zone];
    info->_shouldBadge = _shouldBadge;
    info->_shouldSendContentAvailable = _shouldSendContentAvailable;
    info->_desiredKeys = [_desiredKeys copyWithZone:zone];

    return info;
}

@end
