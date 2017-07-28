//
//  SKYSubscriptionDeserializerTests.m
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

#import <Foundation/Foundation.h>
#import <SKYKit/SKYKit.h>

SpecBegin(SKYSubscriptionDeserializer)

    describe(@"deserialize subscription", ^{
        __block SKYSubscriptionDeserializer *deserializer = nil;

        beforeEach(^{
            deserializer = [SKYSubscriptionDeserializer deserializer];
        });

        it(@"init", ^{
            SKYSubscriptionDeserializer *deserializer = [SKYSubscriptionDeserializer deserializer];
            expect([deserializer class]).to.beSubclassOf([SKYSubscriptionDeserializer class]);
        });

        it(@"deserialize nil to nil", ^{
            SKYSubscription *subscription = [deserializer subscriptionWithDictionary:nil];
            expect(subscription).to.equal(nil);
        });

        it(@"deserialize empty to nil", ^{
            SKYSubscription *subscription = [deserializer subscriptionWithDictionary:@{}];
            expect(subscription).to.equal(nil);
        });

        it(@"deserialize dictionary without id to nil", ^{
            SKYSubscription *subscription =
                [deserializer subscriptionWithDictionary:@{@"type" : @"query"}];
            expect(subscription).to.equal(nil);
        });

        it(@"deserialize dictionary without type to nil", ^{
            SKYSubscription *subscription =
                [deserializer subscriptionWithDictionary:@{@"id" : @"subscriptionID"}];
            expect(subscription).to.equal(nil);
        });

        it(@"deserialize query subscription", ^{
            NSDictionary *subscriptionDict = @{
                @"id" : @"subscriptionID",
                @"type" : @"query",
            };

            SKYSubscription *subscription =
                [deserializer subscriptionWithDictionary:subscriptionDict];

            expect(subscription.subscriptionType).to.equal(SKYSubscriptionTypeQuery);
            expect(subscription.subscriptionID).to.equal(@"subscriptionID");
            expect(subscription.query).to.equal(nil);
        });

        it(@"deserialize dictionary with unknown type to nil", ^{
            SKYSubscription *subscription = [deserializer subscriptionWithDictionary:@{
                @"id" : @"subscriptionID",
                @"type" : @"notexisttype",

            }];
            expect(subscription).to.equal(nil);
        });

        it(@"deserialize query subscription with query", ^{
            NSDictionary *subscriptionDict = @{
                @"id" : @"subscriptionID",
                @"type" : @"query",
                @"query" : @{
                    @"record_type" : @"recordType",
                    @"predicate" : @[ @"eq", @{@"$type" : @"keypath", @"$val" : @"name"}, @"John" ],
                },
            };

            SKYSubscription *subscription =
                [deserializer subscriptionWithDictionary:subscriptionDict];
            expect(subscription.subscriptionType).to.equal(SKYSubscriptionTypeQuery);
            expect(subscription.subscriptionID).to.equal(@"subscriptionID");
            expect(subscription.query.recordType).to.equal(@"recordType");
            expect(subscription.query.predicate)
                .to.equal([NSPredicate predicateWithFormat:@"name = %@", @"John"]);
        });

        it(@"deserialize subscription with notification info", ^{
            NSDictionary *subscriptionDict = @{
                @"id" : @"subscriptionID",
                @"type" : @"query",
                @"notification_info" : @{
                    @"apns" : @{
                        @"aps" : @{
                            @"alert" : @{
                                @"body" : @"alertBody",
                                @"action-loc-key" : @"alertActionLocalizationKey",
                                @"loc-key" : @"alertLocalizationKey",
                                @"loc-args" : @[ @"arg0", @"arg1" ],
                                @"launch-image" : @"alertLaunchImage",
                            },
                            @"sound" : @"soundName",
                            @"should-badge" : @YES,
                            @"should-send-content-available" : @YES,
                        },
                    },
                },
            };

            SKYSubscription *subscription =
                [deserializer subscriptionWithDictionary:subscriptionDict];
            expect(subscription.subscriptionType).to.equal(SKYSubscriptionTypeQuery);
            expect(subscription.subscriptionID).to.equal(@"subscriptionID");

            SKYAPSNotificationInfo *expectedAPSNotificationInfo =
                [SKYAPSNotificationInfo notificationInfo];
            expectedAPSNotificationInfo.alertBody = @"alertBody";
            expectedAPSNotificationInfo.alertActionLocalizationKey = @"alertActionLocalizationKey";
            expectedAPSNotificationInfo.alertLocalizationKey = @"alertLocalizationKey";
            expectedAPSNotificationInfo.alertLocalizationArgs = @[ @"arg0", @"arg1" ];
            expectedAPSNotificationInfo.alertLaunchImage = @"alertLaunchImage";
            expectedAPSNotificationInfo.soundName = @"soundName";
            expectedAPSNotificationInfo.shouldBadge = YES;
            expectedAPSNotificationInfo.shouldSendContentAvailable = YES;

            SKYNotificationInfo *expectedNotificationInfo = [[SKYNotificationInfo alloc] init];
            expectedNotificationInfo.apsNotificationInfo = expectedAPSNotificationInfo;

            expect(subscription.notificationInfo).to.equal(expectedNotificationInfo);
        });
    });

describe(@"deserialize notification info", ^{
    __block SKYNotificationInfoDeserializer *deserializer = nil;

    beforeEach(^{
        deserializer = [SKYNotificationInfoDeserializer deserializer];
    });

    it(@"deserialize nil", ^{
        SKYNotificationInfo *notificationInfo = [deserializer notificationInfoWithDictionary:nil];
        expect(notificationInfo).to.equal(nil);
    });

    it(@"deserialize empty dicty", ^{
        SKYNotificationInfo *notificationInfo = [deserializer notificationInfoWithDictionary:@{}];
        expect(notificationInfo).to.equal(nil);
    });

    it(@"deserialize full notification info", ^{
        NSDictionary *notificationInfoDict = @{
            @"apns" : @{
                @"aps" : @{
                    @"alert" : @{
                        @"body" : @"alertBody",
                        @"action-loc-key" : @"alertActionLocalizationKey",
                        @"loc-key" : @"alertLocalizationKey",
                        @"loc-args" : @[ @"arg0", @"arg1" ],
                        @"launch-image" : @"alertLaunchImage",
                    },
                    @"sound" : @"soundName",
                    @"should-badge" : @YES,
                    @"should-send-content-available" : @YES,
                },
            },
            @"desired_keys" : @[ @"key0", @"key1" ],
        };

        SKYNotificationInfo *notificationInfo =
            [deserializer notificationInfoWithDictionary:notificationInfoDict];

        SKYAPSNotificationInfo *expectedAPSNotificationInfo =
            [SKYAPSNotificationInfo notificationInfo];
        expectedAPSNotificationInfo.alertBody = @"alertBody";
        expectedAPSNotificationInfo.alertActionLocalizationKey = @"alertActionLocalizationKey";
        expectedAPSNotificationInfo.alertLocalizationKey = @"alertLocalizationKey";
        expectedAPSNotificationInfo.alertLocalizationArgs = @[ @"arg0", @"arg1" ];
        expectedAPSNotificationInfo.alertLaunchImage = @"alertLaunchImage";
        expectedAPSNotificationInfo.soundName = @"soundName";
        expectedAPSNotificationInfo.shouldBadge = YES;
        expectedAPSNotificationInfo.shouldSendContentAvailable = YES;

        SKYNotificationInfo *expectedNotificationInfo = [[SKYNotificationInfo alloc] init];
        expectedNotificationInfo.apsNotificationInfo = expectedAPSNotificationInfo;
        expectedNotificationInfo.desiredKeys = @[ @"key0", @"key1" ];

        expect(notificationInfo).to.equal(expectedNotificationInfo);
    });

});

SpecEnd
