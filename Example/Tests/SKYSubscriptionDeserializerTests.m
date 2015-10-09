//
//  SKYSubscriptionDeserializerTests.m
//  SkyKit
//
//  Created by Kenji Pa on 23/4/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SkyKit/SkyKit.h>

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
        SKYSubscription *subscription = [deserializer subscriptionWithDictionary:@{@"type": @"query"}];
        expect(subscription).to.equal(nil);
    });

    it(@"deserialize dictionary without type to nil", ^{
        SKYSubscription *subscription = [deserializer subscriptionWithDictionary:@{@"id": @"subscriptionID"}];
        expect(subscription).to.equal(nil);
    });


    it(@"deserialize query subscription", ^{
        NSDictionary *subscriptionDict = @{
                                           @"id": @"subscriptionID",
                                           @"type": @"query",
                                           };
        
        SKYSubscription *subscription = [deserializer subscriptionWithDictionary:subscriptionDict];

        expect(subscription.subscriptionType).to.equal(SKYSubscriptionTypeQuery);
        expect(subscription.subscriptionID).to.equal(@"subscriptionID");
        expect(subscription.query).to.equal(nil);
    });

    it(@"deserialize dictionary with unknown type to nil", ^{
        SKYSubscription *subscription = [deserializer subscriptionWithDictionary:@{
                                                                                  @"id": @"subscriptionID",
                                                                                  @"type": @"notexisttype",

                                                                                  }];
        expect(subscription).to.equal(nil);
    });

    it(@"deserialize query subscription with query", ^{
        NSDictionary *subscriptionDict = @{
                                           @"id": @"subscriptionID",
                                           @"type": @"query",
                                           @"query": @{
                                                   @"record_type": @"recordType",
                                                   @"predicate": @[@"eq", @{@"$type": @"keypath", @"$val": @"name"}, @"John"],
                                                   },
                                           };

        SKYSubscription *subscription = [deserializer subscriptionWithDictionary:subscriptionDict];
        expect(subscription.subscriptionType).to.equal(SKYSubscriptionTypeQuery);
        expect(subscription.subscriptionID).to.equal(@"subscriptionID");
        expect(subscription.query.recordType).to.equal(@"recordType");
        expect(subscription.query.predicate).to.equal([NSPredicate predicateWithFormat:@"name = %@", @"John"]);
    });

    it(@"deserialize subscription with notification info", ^{
        NSDictionary *subscriptionDict = @{
                                           @"id": @"subscriptionID",
                                           @"type": @"query",
                                           @"notification_info": @{
                                                   @"aps": @{
                                                           @"alert": @{
                                                                   @"body": @"alertBody",
                                                                   @"action-loc-key": @"alertActionLocalizationKey",
                                                                   @"loc-key": @"alertLocalizationKey",
                                                                   @"loc-args": @[@"arg0", @"arg1"],
                                                                   @"launch-image": @"alertLaunchImage",
                                                                   },
                                                           @"sound": @"soundName",
                                                           @"should-badge": @YES,
                                                           @"should-send-content-available": @YES,
                                                           },
                                                   },
                                           };

        SKYSubscription *subscription = [deserializer subscriptionWithDictionary:subscriptionDict];
        expect(subscription.subscriptionType).to.equal(SKYSubscriptionTypeQuery);
        expect(subscription.subscriptionID).to.equal(@"subscriptionID");

        SKYNotificationInfo *expectedNotificationInfo = [[SKYNotificationInfo alloc] init];
        expectedNotificationInfo.alertBody = @"alertBody";
        expectedNotificationInfo.alertActionLocalizationKey = @"alertActionLocalizationKey";
        expectedNotificationInfo.alertLocalizationKey = @"alertLocalizationKey";
        expectedNotificationInfo.alertLocalizationArgs = @[@"arg0", @"arg1"];
        expectedNotificationInfo.alertLaunchImage = @"alertLaunchImage";
        expectedNotificationInfo.soundName = @"soundName";
        expectedNotificationInfo.shouldBadge = YES;
        expectedNotificationInfo.shouldSendContentAvailable = YES;
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
                                               @"aps": @{
                                                       @"alert": @{
                                                               @"body": @"alertBody",
                                                               @"action-loc-key": @"alertActionLocalizationKey",
                                                               @"loc-key": @"alertLocalizationKey",
                                                               @"loc-args": @[@"arg0", @"arg1"],
                                                               @"launch-image": @"alertLaunchImage",
                                                               },
                                                       @"sound": @"soundName",
                                                       @"should-badge": @YES,
                                                       @"should-send-content-available": @YES,
                                                       },
                                               @"desired_keys": @[@"key0", @"key1"],
                                               };

        SKYNotificationInfo *notificationInfo = [deserializer notificationInfoWithDictionary:notificationInfoDict];

        SKYNotificationInfo *expectedNotificationInfo = [[SKYNotificationInfo alloc] init];
        expectedNotificationInfo.alertBody = @"alertBody";
        expectedNotificationInfo.alertActionLocalizationKey = @"alertActionLocalizationKey";
        expectedNotificationInfo.alertLocalizationKey = @"alertLocalizationKey";
        expectedNotificationInfo.alertLocalizationArgs = @[@"arg0", @"arg1"];
        expectedNotificationInfo.alertLaunchImage = @"alertLaunchImage";
        expectedNotificationInfo.soundName = @"soundName";
        expectedNotificationInfo.shouldBadge = YES;
        expectedNotificationInfo.shouldSendContentAvailable = YES;
        expectedNotificationInfo.desiredKeys = @[@"key0", @"key1"];
        expect(notificationInfo).to.equal(expectedNotificationInfo);
    });

});

SpecEnd
