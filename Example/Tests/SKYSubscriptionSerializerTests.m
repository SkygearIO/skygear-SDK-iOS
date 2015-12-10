//
//  SKYSubscriptionSerializerTests.m
//  SkyKit
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

#import <Foundation/Foundation.h>
#import <SkyKit/SkyKit.h>

SpecBegin(SKYSubscriptionSerializer)

    describe(@"serialize subscription", ^{
        __block SKYSubscriptionSerializer *serializer = nil;

        beforeEach(^{
            serializer = [SKYSubscriptionSerializer serializer];
        });

        it(@"init", ^{
            SKYSubscriptionSerializer *serializer = [SKYSubscriptionSerializer serializer];
            expect([serializer class]).to.beSubclassOf([SKYSubscriptionSerializer class]);
        });

        it(@"serialize query subscription", ^{
            SKYSubscription *subscription = [[SKYSubscription alloc]
                initWithQuery:[[SKYQuery alloc] initWithRecordType:@"recordType" predicate:nil]];
            NSDictionary *result = [serializer dictionaryWithSubscription:subscription];
            expect([result class]).to.beSubclassOf([NSDictionary class]);
            expect(result).to.equal(@{
                @"type" : @"query",
                @"query" : @{
                    @"record_type" : @"recordType",
                },
            });
        });

        it(@"serialize query subscription with id", ^{
            SKYSubscription *subscription = [[SKYSubscription alloc]
                 initWithQuery:[[SKYQuery alloc] initWithRecordType:@"recordType" predicate:nil]
                subscriptionID:@"somesubscriptionid"];
            NSDictionary *result = [serializer dictionaryWithSubscription:subscription];
            expect([result class]).to.beSubclassOf([NSDictionary class]);
            expect(result).to.equal(@{
                @"type" : @"query",
                @"id" : @"somesubscriptionid",
                @"query" : @{
                    @"record_type" : @"recordType",
                },
            });
        });

        it(@"serialize subscription with notificatoin info", ^{
            SKYSubscription *subscription = [[SKYSubscription alloc]
                initWithQuery:[[SKYQuery alloc] initWithRecordType:@"recordType" predicate:nil]];

            SKYAPSNotificationInfo *apsNotificationInfo = [SKYAPSNotificationInfo notificationInfo];
            apsNotificationInfo.alertBody = @"alertBody";
            apsNotificationInfo.alertActionLocalizationKey = @"alertActionLocalizationKey";
            apsNotificationInfo.alertLocalizationArgs = @[ @"arg0", @"arg1" ];
            apsNotificationInfo.alertActionLocalizationKey = @"alertActionLocalizationKey";
            apsNotificationInfo.alertLaunchImage = @"alertLaunchImage";
            apsNotificationInfo.soundName = @"soundName";
            apsNotificationInfo.shouldBadge = YES;
            apsNotificationInfo.shouldSendContentAvailable = YES;

            SKYNotificationInfo *notificationInfo = [SKYNotificationInfo notificationInfo];
            notificationInfo.apsNotificationInfo = apsNotificationInfo;
            notificationInfo.desiredKeys = @[ @"key0", @"key1" ];

            subscription.notificationInfo = notificationInfo;

            NSDictionary *result = [serializer dictionaryWithSubscription:subscription];
            expect(result).to.equal(@{
                @"type" : @"query",
                @"query" : @{@"record_type" : @"recordType"},
                @"notification_info" : @{
                    @"apns" : @{
                        @"aps" : @{
                            @"alert" : @{
                                @"body" : @"alertBody",
                                @"action-loc-key" : @"alertActionLocalizationKey",
                                @"loc-args" : @[ @"arg0", @"arg1" ],
                                @"action-loc-key" : @"alertActionLocalizationKey",
                                @"launch-image" : @"alertLaunchImage",
                            },
                            @"sound" : @"soundName",
                            @"should-badge" : @YES,
                            @"should-send-content-available" : @YES,
                        },
                    },
                    @"desired_keys" : @[ @"key0", @"key1" ],
                },
            });
        });
    });

describe(@"serialize notification info", ^{
    __block SKYNotificationInfoSerializer *serializer = nil;

    beforeEach(^{
        serializer = [SKYNotificationInfoSerializer serializer];
    });

    it(@"serialize aps notification info", ^{
        SKYAPSNotificationInfo *apsInfo = [SKYAPSNotificationInfo notificationInfo];
        apsInfo.alertBody = @"alertBody";
        apsInfo.alertActionLocalizationKey = @"alertActionLocalizationKey";
        apsInfo.alertLocalizationArgs = @[ @"arg0", @"arg1" ];
        apsInfo.alertActionLocalizationKey = @"alertActionLocalizationKey";
        apsInfo.alertLaunchImage = @"alertLaunchImage";
        apsInfo.soundName = @"soundName";
        apsInfo.shouldBadge = YES;
        apsInfo.shouldSendContentAvailable = YES;

        SKYNotificationInfo *info = [SKYNotificationInfo notificationInfo];
        info.apsNotificationInfo = apsInfo;
        info.desiredKeys = @[ @"key0", @"key1" ];

        NSDictionary *result = [serializer dictionaryWithNotificationInfo:info];
        expect(result).to.equal(@{
            @"apns" : @{
                @"aps" : @{
                    @"alert" : @{
                        @"body" : @"alertBody",
                        @"action-loc-key" : @"alertActionLocalizationKey",
                        @"loc-args" : @[ @"arg0", @"arg1" ],
                        @"action-loc-key" : @"alertActionLocalizationKey",
                        @"launch-image" : @"alertLaunchImage",
                    },
                    @"sound" : @"soundName",
                    @"should-badge" : @YES,
                    @"should-send-content-available" : @YES,
                },
            },
            @"desired_keys" : @[ @"key0", @"key1" ],
        });
    });

    it(@"keep apns empty loc-args item", ^{
        SKYAPSNotificationInfo *apsInfo = [SKYAPSNotificationInfo notificationInfo];
        apsInfo.alertLocalizationArgs = @[ @"arg0", @"", @"arg2" ];

        SKYNotificationInfo *info = [SKYNotificationInfo notificationInfo];
        info.apsNotificationInfo = apsInfo;

        NSDictionary *result = [serializer dictionaryWithNotificationInfo:info];
        expect(result).to.equal(@{
            @"apns" : @{
                @"aps" : @{
                    @"alert" : @{
                        @"loc-args" : @[ @"arg0", @"", @"arg2" ],
                    },
                },
            }
        });
    });

    it(@"serialize gcm notification info", ^{
        SKYGCMNotificationInfo *gcmInfo = [SKYGCMNotificationInfo notificationInfo];
        gcmInfo.collapseKey = @"collapseKey";
        gcmInfo.priority = 1;
        gcmInfo.contentAvailable = YES;
        gcmInfo.delayWhileIdle = YES;
        gcmInfo.timeToLive = 1;
        gcmInfo.restrictedPackageName = @"restrictedPackageName";

        gcmInfo.notification.title = @"title";
        gcmInfo.notification.body = @"body";
        gcmInfo.notification.icon = @"icon";
        gcmInfo.notification.sound = @"sound";
        gcmInfo.notification.tag = @"tag";
        gcmInfo.notification.clickAction = @"clickAction";
        gcmInfo.notification.bodyLocKey = @"bodyLocKey";
        gcmInfo.notification.bodyLocArgs = @[ @"bodyLocArg0", @"bodyLocArg1" ];
        gcmInfo.notification.titleLocKey = @"titleLocKey";
        gcmInfo.notification.titleLocArgs = @[ @"titleLocArg0", @"titleLocArg1" ];

        SKYNotificationInfo *info = [SKYNotificationInfo notificationInfo];
        info.gcmNotificationInfo = gcmInfo;
        info.desiredKeys = @[ @"key0", @"key1" ];

        NSDictionary *result = [serializer dictionaryWithNotificationInfo:info];
        expect(result).to.equal(@{
            @"gcm" : @{
                @"collapse_key" : @"collapseKey",
                @"priority" : @1,
                @"content_available" : @YES,
                @"delay_while_idle" : @YES,
                @"time_to_live" : @1,
                @"restricted_package_name" : @"restrictedPackageName",
                @"notification" : @{
                    @"title" : @"title",
                    @"body" : @"body",
                    @"icon" : @"icon",
                    @"sound" : @"sound",
                    @"tag" : @"tag",
                    @"click_action" : @"clickAction",
                    @"body_loc_key" : @"bodyLocKey",
                    @"body_loc_args" : @[ @"bodyLocArg0", @"bodyLocArg1" ],
                    @"title_loc_key" : @"titleLocKey",
                    @"title_loc_args" : @[ @"titleLocArg0", @"titleLocArg1" ],
                },
            },
            @"desired_keys" : @[ @"key0", @"key1" ],
        });
    });

    it(@"serialize nil", ^{
        NSDictionary *result = [serializer dictionaryWithNotificationInfo:nil];
        expect(result).to.equal(@{});
    });
});

SpecEnd
