//
//  SKYSubscriptionSerializerTests.m
//  SkyKit
//
//  Created by Kenji Pa on 21/4/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

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
        SKYSubscription *subscription = [[SKYSubscription alloc] initWithQuery:[[SKYQuery alloc] initWithRecordType:@"recordType" predicate:nil]];
        NSDictionary *result = [serializer dictionaryWithSubscription:subscription];
        expect([result class]).to.beSubclassOf([NSDictionary class]);
        expect(result).to.equal(@{
                                  @"type": @"query",
                                  @"query": @{
                                          @"record_type": @"recordType",
                                          },
                                  });
    });

    it(@"serialize query subscription with id", ^{
        SKYSubscription *subscription = [[SKYSubscription alloc] initWithQuery:[[SKYQuery alloc] initWithRecordType:@"recordType" predicate:nil] subscriptionID:@"somesubscriptionid"];
        NSDictionary *result = [serializer dictionaryWithSubscription:subscription];
        expect([result class]).to.beSubclassOf([NSDictionary class]);
        expect(result).to.equal(@{
                                  @"type": @"query",
                                  @"id": @"somesubscriptionid",
                                  @"query": @{
                                          @"record_type": @"recordType",
                                          },
                                  });
    });

    it(@"serialize subscription with notificatoin info", ^{
        SKYSubscription *subscription = [[SKYSubscription alloc] initWithQuery:[[SKYQuery alloc] initWithRecordType:@"recordType" predicate:nil]];

        SKYAPSNotificationInfo *apsNotificationInfo = [SKYAPSNotificationInfo notificationInfo];
        apsNotificationInfo.alertBody = @"alertBody";
        apsNotificationInfo.alertActionLocalizationKey = @"alertActionLocalizationKey";
        apsNotificationInfo.alertLocalizationArgs = @[@"arg0", @"arg1"];
        apsNotificationInfo.alertActionLocalizationKey = @"alertActionLocalizationKey";
        apsNotificationInfo.alertLaunchImage = @"alertLaunchImage";
        apsNotificationInfo.soundName = @"soundName";
        apsNotificationInfo.shouldBadge = YES;
        apsNotificationInfo.shouldSendContentAvailable = YES;

        SKYNotificationInfo *notificationInfo = [SKYNotificationInfo notificationInfo];
        notificationInfo.apsNotificationInfo = apsNotificationInfo;
        notificationInfo.desiredKeys = @[@"key0", @"key1"];

        subscription.notificationInfo = notificationInfo;

        NSDictionary *result = [serializer dictionaryWithSubscription:subscription];
        expect(result).to.equal(@{
                                  @"type": @"query",
                                  @"query": @{@"record_type": @"recordType"},
                                  @"notification_info": @{
                                          @"aps": @{
                                                  @"alert": @{
                                                          @"body": @"alertBody",
                                                          @"action-loc-key": @"alertActionLocalizationKey",
                                                          @"loc-args": @[@"arg0", @"arg1"],
                                                          @"action-loc-key": @"alertActionLocalizationKey",
                                                          @"launch-image": @"alertLaunchImage",
                                                  },
                                                  @"sound": @"soundName",
                                                  @"should-badge": @YES,
                                                  @"should-send-content-available": @YES,
                                                  },
                                          @"desired_keys": @[@"key0", @"key1"],
                                          },
                                  });
    });
});

describe(@"serialize notification info", ^{
    __block SKYNotificationInfoSerializer *serializer = nil;

    beforeEach(^{
        serializer = [SKYNotificationInfoSerializer serializer];
    });

    it(@"serialize notification info", ^{
        SKYAPSNotificationInfo *apsInfo = [SKYAPSNotificationInfo notificationInfo];
        apsInfo.alertBody = @"alertBody";
        apsInfo.alertActionLocalizationKey = @"alertActionLocalizationKey";
        apsInfo.alertLocalizationArgs = @[@"arg0", @"arg1"];
        apsInfo.alertActionLocalizationKey = @"alertActionLocalizationKey";
        apsInfo.alertLaunchImage = @"alertLaunchImage";
        apsInfo.soundName = @"soundName";
        apsInfo.shouldBadge = YES;
        apsInfo.shouldSendContentAvailable = YES;

        SKYNotificationInfo *info = [SKYNotificationInfo notificationInfo];
        info.apsNotificationInfo = apsInfo;
        info.desiredKeys = @[@"key0", @"key1"];

        NSDictionary *result = [serializer dictionaryWithNotificationInfo:info];
        expect(result).to.equal(@{
                                  @"aps": @{
                                          @"alert": @{
                                                  @"body": @"alertBody",
                                                  @"action-loc-key": @"alertActionLocalizationKey",
                                                  @"loc-args": @[@"arg0", @"arg1"],
                                                  @"action-loc-key": @"alertActionLocalizationKey",
                                                  @"launch-image": @"alertLaunchImage",
                                                  },
                                          @"sound": @"soundName",
                                          @"should-badge": @YES,
                                          @"should-send-content-available": @YES,
                                          },
                                  @"desired_keys": @[@"key0", @"key1"],
                                  });
    });

    it(@"serialize nil", ^{
        NSDictionary *result = [serializer dictionaryWithNotificationInfo:nil];
        expect(result).to.equal(@{});
    });

    it(@"keep empty loc-args item", ^{
        SKYAPSNotificationInfo *apsInfo = [SKYAPSNotificationInfo notificationInfo];
        apsInfo.alertLocalizationArgs = @[@"arg0", @"", @"arg2"];

        SKYNotificationInfo *info = [SKYNotificationInfo notificationInfo];
        info.apsNotificationInfo = apsInfo;

        NSDictionary *result = [serializer dictionaryWithNotificationInfo:info];
        expect(result).to.equal(@{
                                  @"aps": @{
                                          @"alert": @{
                                                  @"loc-args": @[@"arg0", @"", @"arg2"],
                                                  },
                                          },
                                  });
    });
});

SpecEnd
