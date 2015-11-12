//
//  SKYNotificationInfoSerializer.m
//  Pods
//
//  Created by Kenji Pa on 14/5/15.
//
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
        infoDict[@"aps"] = apsDict;
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
        NSMutableArray *alertLocalizationArgs = [NSMutableArray array];
        for (NSString *arg in n.alertLocalizationArgs) {
            [alertLocalizationArgs addObject:arg];
        }
        if (alertLocalizationArgs.count) {
            alertDict[@"loc-args"] = alertLocalizationArgs;
        }
    }
    if (n.alertActionLocalizationKey) {
        alertDict[@"action-loc-key"] = n.alertActionLocalizationKey;
    }
    if (n.alertLaunchImage) {
        alertDict[@"launch-image"] = n.alertLaunchImage;
    }
    return alertDict;
}

@end
