//
//  SKYNotificationInfoDeserializer.m
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

#import "SKYNotificationInfoDeserializer.h"

#import "SKYAPSNotificationInfo.h"

@implementation SKYNotificationInfoDeserializer

+ (instancetype)deserializer
{
    return [[SKYNotificationInfoDeserializer alloc] init];
}

- (SKYNotificationInfo *)notificationInfoWithDictionary:(NSDictionary *)dictionary
{
    if (!dictionary.count) {
        return nil;
    }

    SKYNotificationInfo *info = [SKYNotificationInfo notificationInfo];
    info.apsNotificationInfo = [self notificationInfoWithApsDictionary:dictionary[@"apns"][@"aps"]];
    info.desiredKeys = dictionary[@"desired_keys"];

    return info;
}

- (SKYAPSNotificationInfo *)notificationInfoWithApsDictionary:(NSDictionary *)dictionary
{
    if (!dictionary.count) {
        return nil;
    }

    SKYAPSNotificationInfo *info = [[SKYAPSNotificationInfo alloc] init];

    NSDictionary *alertDict = dictionary[@"alert"];
    info.alertBody = alertDict[@"body"];
    info.alertActionLocalizationKey = alertDict[@"action-loc-key"];
    info.alertLocalizationKey = alertDict[@"loc-key"];
    info.alertLocalizationArgs = alertDict[@"loc-args"];
    info.alertLaunchImage = alertDict[@"launch-image"];

    info.soundName = dictionary[@"sound"];
    info.shouldBadge = [dictionary[@"should-badge"] boolValue];
    info.shouldSendContentAvailable = [dictionary[@"should-send-content-available"] boolValue];

    return info;
}

@end
