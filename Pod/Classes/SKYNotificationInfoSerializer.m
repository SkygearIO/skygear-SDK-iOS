//
//  SKYNotificationInfoSerializer.m
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

#import "SKYNotificationInfoSerializer.h"

@implementation SKYNotificationInfoSerializer

+ (instancetype)serializer
{
    return [[SKYNotificationInfoSerializer alloc] init];
}

- (NSDictionary *)dictionaryWithNotificationInfo:(SKYNotificationInfo *)n
{
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];

    NSDictionary *apsDict = [self apsDictionaryWithNotificationInfo:n.apsNotificationInfo];
    if (apsDict.count) {
        infoDict[@"apns"] = @{@"aps" : apsDict};
    }

    NSDictionary *gcmDict = [self gcmDictionaryWithNotificationInfo:n.gcmNotificationInfo];
    if (gcmDict.count) {
        infoDict[@"gcm"] = gcmDict;
    }

    if (n.desiredKeys.count) {
        infoDict[@"desired_keys"] = [n.desiredKeys copy];
    }

    return infoDict;
}

- (NSDictionary *)apsDictionaryWithNotificationInfo:(SKYAPSNotificationInfo *)n
{
    NSMutableDictionary *apsDict = [NSMutableDictionary dictionary];

    NSDictionary *alertDict = [self alertDictionaryWithNotificationInfo:n];
    if (alertDict.count) {
        apsDict[@"alert"] = alertDict;
    }
    if (n.soundName) {
        apsDict[@"sound"] = n.soundName;
    }
    if (n.shouldBadge) {
        apsDict[@"should-badge"] = @YES;
    }
    if (n.shouldSendContentAvailable) {
        apsDict[@"should-send-content-available"] = @YES;
    }
    return apsDict;
}

- (NSDictionary *)alertDictionaryWithNotificationInfo:(SKYAPSNotificationInfo *)n
{
    NSMutableDictionary *alertDict = [[NSMutableDictionary alloc] init];
    if (n.alertBody) {
        alertDict[@"body"] = n.alertBody;
    }
    if (n.alertLocalizationKey) {
        alertDict[@"loc-key"] = n.alertLocalizationKey;
    }
    if (n.alertLocalizationArgs.count) {
        alertDict[@"loc-args"] = [n.alertLocalizationArgs copy];
    }
    if (n.alertActionLocalizationKey) {
        alertDict[@"action-loc-key"] = n.alertActionLocalizationKey;
    }
    if (n.alertLaunchImage) {
        alertDict[@"launch-image"] = n.alertLaunchImage;
    }
    return alertDict;
}

- (NSDictionary *)gcmDictionaryWithNotificationInfo:(SKYGCMNotificationInfo *)n
{
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];

    if (n.collapseKey.length) {
        infoDict[@"collapse_key"] = n.collapseKey;
    }
    if (n.priority) {
        infoDict[@"priority"] = @(n.priority);
    }
    if (n.contentAvailable) {
        infoDict[@"content_available"] = @YES;
    }
    if (n.delayWhileIdle) {
        infoDict[@"delay_while_idle"] = @YES;
    }
    if (n.timeToLive) {
        infoDict[@"time_to_live"] = @(n.timeToLive);
    }
    if (n.restrictedPackageName.length) {
        infoDict[@"restricted_package_name"] = n.restrictedPackageName;
    }

    NSDictionary *innerInfoDict = [self dictionaryWithGCMInnerNotificationInfo:n.notification];
    if (innerInfoDict.count) {
        infoDict[@"notification"] = innerInfoDict;
    }

    return infoDict;
}

- (NSDictionary *)dictionaryWithGCMInnerNotificationInfo:(SKYGCMInnerNotificationInfo *)n
{
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
    if (n.title.length) {
        infoDict[@"title"] = n.title;
    }
    if (n.body.length) {
        infoDict[@"body"] = n.body;
    }
    if (n.icon.length) {
        infoDict[@"icon"] = n.icon;
    }
    if (n.sound.length) {
        infoDict[@"sound"] = n.sound;
    }
    if (n.tag.length) {
        infoDict[@"tag"] = n.tag;
    }
    if (n.clickAction.length) {
        infoDict[@"click_action"] = n.clickAction;
    }
    if (n.bodyLocKey.length) {
        infoDict[@"body_loc_key"] = n.bodyLocKey;
    }
    if (n.bodyLocArgs.count) {
        infoDict[@"body_loc_args"] = [n.bodyLocArgs copy];
    }
    if (n.titleLocKey.length) {
        infoDict[@"title_loc_key"] = n.titleLocKey;
    }
    if (n.titleLocArgs.count) {
        infoDict[@"title_loc_args"] = [n.titleLocArgs copy];
    }
    return infoDict;
}

@end
