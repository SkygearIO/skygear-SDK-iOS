//
//  ODNotificationInfoSerializer.m
//  Pods
//
//  Created by Kenji Pa on 14/5/15.
//
//

#import "ODNotificationInfoSerializer.h"

@implementation ODNotificationInfoSerializer

+ (instancetype)serializer
{
    return [[ODNotificationInfoSerializer alloc] init];
}

- (NSDictionary *)dictionaryWithNotificationInfo:(ODNotificationInfo *)n
{
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];

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
    if (apsDict.count) {
        infoDict[@"aps"] = apsDict;
    }

    if (n.desiredKeys.count) {
        NSMutableArray *desiredKeys = [NSMutableArray array];
        for (NSString *key in n.desiredKeys) {
            if (key.length) {
                [desiredKeys addObject:key];
            }
        }
        if (desiredKeys.count) {
            infoDict[@"desired_keys"] = desiredKeys;
        }
    }

    return infoDict;
}

- (NSDictionary *)alertDictionaryWithNotificationInfo:(ODNotificationInfo *)n
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
