//
//  ODSubscriptionDeserializerTests.m
//  ODKit
//
//  Created by Kenji Pa on 23/4/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>

SpecBegin(ODSubscriptionDeserializer)

describe(@"deserialize subscription", ^{
    __block ODSubscriptionDeserializer *deserializer = nil;

    beforeEach(^{
        deserializer = [ODSubscriptionDeserializer deserializer];
    });

    it(@"init", ^{
        ODSubscriptionDeserializer *deserializer = [ODSubscriptionDeserializer deserializer];
        expect([deserializer class]).to.beSubclassOf([ODSubscriptionDeserializer class]);
    });

    it(@"deserialize nil to nil", ^{
        ODSubscription *subscription = [deserializer subscriptionWithDictionary:nil];
        expect(subscription).to.equal(nil);
    });

    it(@"deserialize empty to nil", ^{
        ODSubscription *subscription = [deserializer subscriptionWithDictionary:@{}];
        expect(subscription).to.equal(nil);
    });

    it(@"deserialize dictionary without id to nil", ^{
        ODSubscription *subscription = [deserializer subscriptionWithDictionary:@{@"type": @"query"}];
        expect(subscription).to.equal(nil);
    });

    it(@"deserialize dictionary without type to nil", ^{
        ODSubscription *subscription = [deserializer subscriptionWithDictionary:@{@"id": @"subscriptionID"}];
        expect(subscription).to.equal(nil);
    });


    it(@"deserialize query subscription", ^{
        NSDictionary *subscriptionDict = @{
                                           @"id": @"subscriptionID",
                                           @"type": @"query",
                                           };
        
        ODSubscription *subscription = [deserializer subscriptionWithDictionary:subscriptionDict];

        expect(subscription.subscriptionType).to.equal(ODSubscriptionTypeQuery);
        expect(subscription.subscriptionID).to.equal(@"subscriptionID");
        expect(subscription.query).to.equal(nil);
    });

    it(@"deserialize dictionary with unknown type to nil", ^{
        ODSubscription *subscription = [deserializer subscriptionWithDictionary:@{
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

        ODSubscription *subscription = [deserializer subscriptionWithDictionary:subscriptionDict];
        expect(subscription.subscriptionType).to.equal(ODSubscriptionTypeQuery);
        expect(subscription.subscriptionID).to.equal(@"subscriptionID");
        expect(subscription.query.recordType).to.equal(@"recordType");
        expect(subscription.query.predicate).to.equal([NSPredicate predicateWithFormat:@"name = %@", @"John"]);
    });
});

SpecEnd
