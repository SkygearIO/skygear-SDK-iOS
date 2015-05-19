//
//  ODNotificationTests.m
//  ODKit
//
//  Created by Kenji Pa on 19/5/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <ODKit/ODKit.h>

#import "ODNotification_Private.h"

SpecBegin(ODNotification)

describe(@"ODNotification", ^{
    it(@"built from notification dict", ^{
        NSDictionary *info = @{
                               @"_ourd": @{
                                       @"subscription-id": @"SUBSCRIPTION_ID",
                                       },
                               };
        ODNotification *notification = [ODNotification notificationFromRemoteNotificationDictionary:info];

        expect(notification).notTo.beNil();
        expect(notification.subscriptionID).to.equal(@"SUBSCRIPTION_ID");
    });

    it(@"is nil when built from unrelated notification dict", ^{
        NSDictionary *info = @{
                               @"aps": @{
                                       @"alert": @{
                                               @"title": @"Game Request",
                                               @"body": @"Bob wants to play poker",
                                               @"action-loc-key": @"PLAY",
                                               },
                                       @"badge" : @5,
                                       },
                               @"acme1" : @"bar",
                               @"acme2" : @[@"bang", @"whiz"],
                               };
        ODNotification *notification = [ODNotification notificationFromRemoteNotificationDictionary:info];

        expect(notification).to.beNil();
    });
});

SpecEnd
