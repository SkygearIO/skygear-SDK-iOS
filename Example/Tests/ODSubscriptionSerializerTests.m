//
//  ODSubscriptionSerializerTests.m
//  ODKit
//
//  Created by Kenji Pa on 21/4/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>

SpecBegin(ODSubscriptionSerializer)

describe(@"serialize subscription", ^{
    __block ODSubscriptionSerializer *serializer = nil;

    beforeEach(^{
        serializer = [ODSubscriptionSerializer serializer];
    });

    it(@"init", ^{
        ODSubscriptionSerializer *serializer = [ODSubscriptionSerializer serializer];
        expect([serializer class]).to.beSubclassOf([ODSubscriptionSerializer class]);
    });

    it(@"serialize query subscription", ^{
        ODSubscription *subscription = [[ODSubscription alloc] initWithQuery:[[ODQuery alloc] initWithRecordType:@"recordType" predicate:nil]];
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
        ODSubscription *subscription = [[ODSubscription alloc] initWithQuery:[[ODQuery alloc] initWithRecordType:@"recordType" predicate:nil] subscriptionID:@"somesubscriptionid"];
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
        ODSubscription *subscription = [[ODSubscription alloc] initWithQuery:[[ODQuery alloc] initWithRecordType:@"recordType" predicate:nil]];

        ODNotificationInfo *notificationInfo = [[ODNotificationInfo alloc] init];
        notificationInfo.alertBody = @"alertBody";
        notificationInfo.alertActionLocalizationKey = @"alertActionLocalizationKey";
        notificationInfo.alertLocalizationArgs = @[@"arg0", @"arg1"];
        notificationInfo.alertActionLocalizationKey = @"alertActionLocalizationKey";
        notificationInfo.alertLaunchImage = @"alertLaunchImage";
        notificationInfo.soundName = @"soundName";
        notificationInfo.shouldBadge = YES;
        notificationInfo.shouldSendContentAvailable = YES;
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
    __block ODNotificationInfoSerializer *serializer = nil;

    beforeEach(^{
        serializer = [ODNotificationInfoSerializer serializer];
    });

    it(@"serialize notification info", ^{
        ODNotificationInfo *info = [[ODNotificationInfo alloc] init];
        info.alertBody = @"alertBody";
        info.alertActionLocalizationKey = @"alertActionLocalizationKey";
        info.alertLocalizationArgs = @[@"arg0", @"arg1"];
        info.alertActionLocalizationKey = @"alertActionLocalizationKey";
        info.alertLaunchImage = @"alertLaunchImage";
        info.soundName = @"soundName";
        info.shouldBadge = YES;
        info.shouldSendContentAvailable = YES;
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
        ODNotificationInfo *info = [[ODNotificationInfo alloc] init];
        info.alertLocalizationArgs = @[@"arg0", @"", @"arg2"];

        NSDictionary *result = [serializer dictionaryWithNotificationInfo:info];
        expect(result).to.equal(@{
                                  @"aps": @{
                                          @"alert": @{
                                                  @"loc-args": @[@"arg0", @"", @"arg2"],
                                                  },
                                          },
                                  });
    });

    it(@"skip empty desired keys", ^{
        ODNotificationInfo *info = [[ODNotificationInfo alloc] init];
        info.desiredKeys = @[@"key0", @"", @"key2"];

        NSDictionary *result = [serializer dictionaryWithNotificationInfo:info];
        expect(result).to.equal(@{
                                  @"desired_keys": @[@"key0", @"key2"],
                                  });
    });

    it(@"skip empty alert", ^{
        ODNotificationInfo *info = [[ODNotificationInfo alloc] init];
        info.shouldSendContentAvailable = YES;

        NSDictionary *result = [serializer dictionaryWithNotificationInfo:info];
        expect(result).to.equal(@{
                                  @"aps": @{
                                          @"should-send-content-available": @YES,
                                          },
                                  });
    });
});

SpecEnd
