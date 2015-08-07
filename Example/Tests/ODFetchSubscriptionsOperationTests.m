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
        [container updateWithUserRecordID:[ODUserRecordID recordIDWithUsername:@"USER_ID"]
                              accessToken:[[ODAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];
        database = [container publicCloudDatabase];
    });

    it(@"single subscription", ^{
        ODFetchSubscriptionsOperation *operation = [ODFetchSubscriptionsOperation operationWithSubscriptionIDs:@[@"sub1"]];
        operation.deviceID = @"DEVICE_ID";
        operation.container = container;
        operation.database = database;

        [operation prepareForRequest];

        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.accessToken).to.equal(container.currentAccessToken);
        expect(request.action).to.equal(@"subscription:fetch");
        expect(request.payload).to.equal(@{
                                           @"database_id": database.databaseID,
                                           @"ids": @[@"sub1"],
                                           @"device_id": @"DEVICE_ID",
                                               });

    });

    it(@"multiple subscriptions", ^{
        ODFetchSubscriptionsOperation *operation = [ODFetchSubscriptionsOperation operationWithSubscriptionIDs:@[@"sub1", @"sub2"]];
        operation.deviceID = @"DEVICE_ID";
        operation.container = container;
        operation.database = database;

        [operation prepareForRequest];

        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.accessToken).to.equal(container.currentAccessToken);
        expect(request.action).to.equal(@"subscription:fetch");
        expect(request.payload).to.equal(@{
                                           @"database_id": database.databaseID,
                                           @"ids": @[@"sub1", @"sub2"],
                                           @"device_id": @"DEVICE_ID",
                                           });
    });

    it(@"make request", ^{
        ODFetchSubscriptionsOperation *operation = [ODFetchSubscriptionsOperation operationWithSubscriptionIDs:@[@"sub1", @"sub2"]];
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
        ODFetchSubscriptionsOperation *operation = [ODFetchSubscriptionsOperation operationWithSubscriptionIDs:@[@"sub1", @"sub2"]];
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

    describe(@"when there exists device id", ^{
        __block ODFetchSubscriptionsOperation *operation;

        beforeEach(^{
            id odDefaultsMock = OCMClassMock(ODDefaults.class);
            OCMStub([odDefaultsMock sharedDefaults]).andReturn(odDefaultsMock);
            OCMStub([odDefaultsMock deviceID]).andReturn(@"EXISTING_DEVICE_ID");

            operation = [[ODFetchSubscriptionsOperation alloc] initWithSubscriptionIDs:@[]];
            operation.container = container;
            operation.database = database;
        });

        it(@"request with device id", ^{
            [operation prepareForRequest];
            expect(operation.request.payload[@"device_id"]).to.equal(@"EXISTING_DEVICE_ID");
        });

        it(@"user-set device id overrides existing device id", ^{
            operation.deviceID = @"ASSIGNED_DEVICE_ID";
            [operation prepareForRequest];
            expect(operation.request.payload[@"device_id"]).to.equal(@"ASSIGNED_DEVICE_ID");
        });
    });

    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });
});

SpecEnd
