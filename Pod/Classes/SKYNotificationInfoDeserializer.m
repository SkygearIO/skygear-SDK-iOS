//
//  SKYNotificationInfoDeserializer.m
//  Pods
//
//  Created by Kenji Pa on 15/5/15.
//
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
