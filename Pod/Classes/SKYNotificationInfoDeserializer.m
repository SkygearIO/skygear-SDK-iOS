//
//  SKYNotificationInfoDeserializer.m
//  Pods
//
//  Created by Kenji Pa on 15/5/15.
//
//

#import "SKYNotificationInfoDeserializer.h"

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

    SKYNotificationInfo *info = [self notificationInfoWithApsDictionary:dictionary[@"aps"]];
    info.desiredKeys = dictionary[@"desired_keys"];

    return info;
}

- (SKYNotificationInfo *)notificationInfoWithApsDictionary:(NSDictionary *)dictionary
{
    if (!dictionary.count) {
        return nil;
    }

    SKYNotificationInfo *info = [[SKYNotificationInfo alloc] init];

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
