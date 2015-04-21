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
});

SpecEnd
