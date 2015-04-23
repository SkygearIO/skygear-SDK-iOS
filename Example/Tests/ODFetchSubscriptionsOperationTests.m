//
//  ODFetchSubscriptionsOperationTests.m
//  ODKit
//
//  Created by Kenji Pa on 23/4/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ODKit/ODKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(ODFetchSubscriptionsOperation)

describe(@"fetch subscription", ^{
    __block ODContainer *container = nil;
    __block ODDatabase *database = nil;

    beforeEach(^{
        container = [[ODContainer alloc] init];
        [container updateWithUserRecordID:[[ODUserRecordID alloc] initWithRecordType:@"user" name:@"USER_ID"]
                              accessToken:[[ODAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];
        database = [container publicCloudDatabase];
    });

    it(@"single subscription", ^{
        ODFetchSubscriptionsOperation *operation = [[ODFetchSubscriptionsOperation alloc] initWithSubscriptionIDs:@[@"sub1"]];
        operation.container = container;
        operation.database = database;

        [operation prepareForRequest];

        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.accessToken).to.equal(container.currentAccessToken);
        expect(request.payload[@"database_id"]).to.equal(database.databaseID);
        expect(request.action).to.equal(@"subscription:fetch");
        expect(request.payload[@"ids"]).to.equal(@[@"sub1"]);

    });

    it(@"multiple subscriptions", ^{
        ODFetchSubscriptionsOperation *operation = [[ODFetchSubscriptionsOperation alloc] initWithSubscriptionIDs:@[@"sub1", @"sub2"]];
        operation.container = container;
        operation.database = database;

        [operation prepareForRequest];

        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.accessToken).to.equal(container.currentAccessToken);
        expect(request.payload[@"database_id"]).to.equal(database.databaseID);
        expect(request.action).to.equal(@"subscription:fetch");
        expect(request.payload[@"ids"]).to.equal(@[@"sub1", @"sub2"]);
    });

    it(@"make request", ^{
        ODFetchSubscriptionsOperation *operation = [[ODFetchSubscriptionsOperation alloc] initWithSubscriptionIDs:@[@"sub1", @"sub2"]];
        operation.container = container;
        operation.database = database;

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         @"request_id": @"REQUEST_ID",
                                         @"database_id": database.databaseID,
                                         @"result": @[
                                                 @{
                                                     @"id": @"sub1",
                                                     @"type": @"query",
                                                     @"query": @{
                                                             @"record_type": @"book",
                                                             }
                                                     },
                                                 @{
                                                     @"id": @"sub2",
                                                     @"type": @"query",
                                                     @"query": @{
                                                             @"record_type": @"bookmark",
                                                             }
                                                     },
                                                 ]
                                         };
            NSData *payload = [NSJSONSerialization dataWithJSONObject:parameters
                                                              options:0
                                                                error:nil];

            return [OHHTTPStubsResponse responseWithData:payload
                                              statusCode:200
                                                 headers:@{}];
        }];

        waitUntil(^(DoneCallback done) {
            operation.fetchSubscriptionCompletionBlock = ^(NSDictionary *subscriptionByID, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect([subscriptionByID class]).to.beSubclassOf([NSDictionary class]);
                    expect(subscriptionByID).to.haveCountOf(2);

                    ODSubscription *sub1 = subscriptionByID[@"sub1"];
                    expect(sub1.subscriptionID).to.equal(@"sub1");
                    expect(sub1.query.recordType).to.equal(@"book");

                    ODSubscription *sub2 = subscriptionByID[@"sub2"];
                    expect(sub2.subscriptionID).to.equal(@"sub2");
                    expect(sub2.query.recordType).to.equal(@"bookmark");

                    done();
                });
            };

            [database executeOperation:operation];
        });
    });

    it(@"pass error", ^{
        ODFetchSubscriptionsOperation *operation = [[ODFetchSubscriptionsOperation alloc] initWithSubscriptionIDs:@[@"sub1", @"sub2"]];
        operation.container = container;
        operation.database = database;
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:nil]];
        }];

        waitUntil(^(DoneCallback done) {
            operation.fetchSubscriptionCompletionBlock = ^(NSDictionary *recordsByRecordID, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(operationError).toNot.beNil();
                    done();
                });
            };
            [database executeOperation:operation];
        });
    });

    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });
});

SpecEnd
