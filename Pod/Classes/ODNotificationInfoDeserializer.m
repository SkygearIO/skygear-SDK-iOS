//
//  ODNotificationInfoDeserializer.m
//  Pods
//
//  Created by Kenji Pa on 15/5/15.
//
//

#import "ODNotificationInfoDeserializer.h"

@implementation ODNotificationInfoDeserializer

+ (instancetype)deserializer
{
    return [[ODNotificationInfoDeserializer alloc] init];
}

- (ODNotificationInfo *)notificationInfoWithDictionary:(NSDictionary *)dictionary
{
    if (!dictionary.count) {
        return nil;
    }

    ODNotificationInfo *info = [self notificationInfoWithApsDictionary:dictionary[@"aps"]];
    info.desiredKeys = dictionary[@"desired_keys"];

    return info;
}

- (ODNotificationInfo *)notificationInfoWithApsDictionary:(NSDictionary *)dictionary
{
    if (!dictionary.count) {
        return nil;
    }

    ODNotificationInfo *info = [[ODNotificationInfo alloc] init];

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
