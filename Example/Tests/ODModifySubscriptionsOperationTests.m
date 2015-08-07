//
//  ODModifySubscriptionsOperationTests.m
//  ODKit
//
//  Created by Kenji Pa on 22/4/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(ODModifySubscriptionsOperation)

describe(@"modify subscription", ^{
    __block ODSubscription *subscription1 = nil;
    __block ODSubscription *subscription2 = nil;
    __block ODContainer *container = nil;
    __block ODDatabase *database = nil;

    beforeEach(^{
        container = [[ODContainer alloc] init];
        [container updateWithUserRecordID:[ODUserRecordID recordIDWithUsername:@"USER_ID"]
                              accessToken:[[ODAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];
        database = [container publicCloudDatabase];
        subscription1 = [[ODSubscription alloc] initWithQuery:nil subscriptionID:@"sub1"];
        subscription2 = [[ODSubscription alloc] initWithQuery:nil subscriptionID:@"sub2"];
    });

    it(@"multiple subscriptions", ^{
        ODModifySubscriptionsOperation *operation = [ODModifySubscriptionsOperation operationWithSubscriptionsToSave:@[subscription1, subscription2]];
        operation.deviceID = @"DEVICE_ID";
        operation.container = container;
        operation.database = database;
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"subscription:save");
        expect(request.accessToken).to.equal(container.currentAccessToken);
        expect(request.payload).to.equal(@{
                                           @"database_id": database.databaseID,
                                           @"subscriptions": @[
                                                   @{@"id": @"sub1", @"type": @"query"},
                                                   @{@"id": @"sub2", @"type": @"query"},
                                                   ],
                                           @"device_id": @"DEVICE_ID",
                                           });
    });

    it(@"make request", ^{
        ODModifySubscriptionsOperation *operation = [ODModifySubscriptionsOperation operationWithSubscriptionsToSave:@[subscription1, subscription2]];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         @"request_id": @"REQUEST_ID",
                                         @"database_id": database.databaseID,
                                         @"result": @[
                                                 @{
                                                     @"id": @"sub1",
                                                     @"type": @"subscription",
                                                     },
                                                 @{
                                                     @"id": @"sub2",
                                                     @"type": @"subscription",
                                                     }
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
            operation.modifySubscriptionsCompletionBlock = ^(NSArray *savedSubscriptions, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect([savedSubscriptions class]).to.beSubclassOf([NSArray class]);
                    expect(savedSubscriptions).to.haveCountOf(2);
                    expect([savedSubscriptions[0] subscriptionID]).to.equal(subscription1.subscriptionID);
                    expect([savedSubscriptions[1] subscriptionID]).to.equal(subscription2.subscriptionID);
                    done();
                });
            };

            [database executeOperation:operation];
        });
    });

    it(@"pass error", ^{
        ODModifySubscriptionsOperation *operation = [ODModifySubscriptionsOperation operationWithSubscriptionsToSave:@[subscription1, subscription2]];
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:nil]];
        }];

        waitUntil(^(DoneCallback done) {
            operation.modifySubscriptionsCompletionBlock = ^(NSArray *savedSubscriptions, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(operationError).toNot.beNil();
                    done();
                });
            };
            [database executeOperation:operation];
        });
    });

    describe(@"when there exists device id", ^{
        __block ODModifySubscriptionsOperation *operation;

        beforeEach(^{
            id odDefaultsMock = OCMClassMock(ODDefaults.class);
            OCMStub([odDefaultsMock sharedDefaults]).andReturn(odDefaultsMock);
            OCMStub([odDefaultsMock deviceID]).andReturn(@"EXISTING_DEVICE_ID");

            operation = [ODModifySubscriptionsOperation operationWithSubscriptionsToSave:@[]];
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
