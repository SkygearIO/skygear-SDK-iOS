//
//  ODDeleteSubscriptionsOperationTests.m
//  ODKit
//
//  Created by Kenji Pa on 17/5/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(ODDeleteSubscriptionsOperation)

describe(@"delete subscription", ^{
    __block ODContainer *container = nil;
    __block ODDatabase *database = nil;

    beforeEach(^{
        container = [[ODContainer alloc] init];
        [container updateWithUserRecordID:[ODUserRecordID recordIDWithUsername:@"USER_ID"]
                              accessToken:[[ODAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];
        database = [container publicCloudDatabase];
    });

    it(@"multiple subscriptions", ^{
        ODDeleteSubscriptionsOperation *operation = [ODDeleteSubscriptionsOperation operationWithSubscriptionIDsToDelete:@[@"my notes", @"ben's notes"]];
        operation.deviceID = @"DEVICE_ID";
        operation.database = database;
        operation.container = container;
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"subscription:delete");
        expect(request.accessToken).to.equal(container.currentAccessToken);
        expect(request.payload).to.equal(@{
                                           @"device_id": @"DEVICE_ID",
                                           @"database_id": database.databaseID,
                                           @"ids": @[@"my notes", @"ben's notes"],
                                           });
    });

    it(@"make request", ^{
        ODDeleteSubscriptionsOperation *operation = [ODDeleteSubscriptionsOperation operationWithSubscriptionIDsToDelete:@[@"my notes", @"ben's notes"]];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         @"request_id": @"REQUEST_ID",
                                         @"database_id": database.databaseID,
                                         @"result": @[
                                                 @{@"id": @"my notes"},
                                                 @{@"id": @"ben's notes"},
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
            operation.deleteSubscriptionsCompletionBlock = ^(NSArray *subscriptionIDs, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(subscriptionIDs).to.equal(@[@"my notes", @"ben's notes"]);
                    expect(operationError).to.beNil();
                    done();
                });
            };

            [database executeOperation:operation];
        });
    });

    it(@"pass error", ^{
        ODDeleteSubscriptionsOperation *operation = [ODDeleteSubscriptionsOperation operationWithSubscriptionIDsToDelete:@[@"my notes", @"ben's notes"]];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:nil]];
        }];

        waitUntil(^(DoneCallback done) {
            operation.deleteSubscriptionsCompletionBlock = ^(NSArray *subscriptionIDs, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(operationError).toNot.beNil();
                    done();
                });
            };

            [database executeOperation:operation];
        });
    });

    it(@"pass per item error", ^{
        ODDeleteSubscriptionsOperation *operation = [ODDeleteSubscriptionsOperation operationWithSubscriptionIDsToDelete:@[@"my notes", @"ben's notes"]];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         @"request_id": @"REQUEST_ID",
                                         @"database_id": database.databaseID,
                                         @"result": @[
                                                 @{@"id": @"my notes"},
                                                 @{
                                                     @"_type": @"error",
                                                     @"_id": @"ben's notes",
                                                     @"message": @"cannot find subscription \"ben's notes\"",
                                                     @"type": @"ResourceNotFound",
                                                     @"code": @101,
                                                     @"info": @{@"id": @"ben's notes"},
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
            operation.deleteSubscriptionsCompletionBlock = ^(NSArray *subscriptionIDs, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(subscriptionIDs).to.equal(@[@"my notes"]);
                    expect(operationError).toNot.beNil();
                    expect(operationError.domain).to.equal(ODOperationErrorDomain);
                    expect(operationError.code).to.equal(ODErrorPartialFailure);

                    NSDictionary *errorBySubscriptionID = operationError.userInfo[ODPartialErrorsByItemIDKey];
                    expect(errorBySubscriptionID).toNot.beNil();
                    NSError *benError = errorBySubscriptionID[@"ben's notes"];
                    expect(benError).toNot.beNil();
                    expect(benError.userInfo).to.equal(@{
                                                         ODErrorCodeKey: @101,
                                                         ODErrorMessageKey: @"cannot find subscription \"ben's notes\"",
                                                         ODErrorTypeKey: @"ResourceNotFound",
                                                         ODErrorInfoKey: @{@"id": @"ben's notes"},
                                                         NSLocalizedDescriptionKey: @"An error occurred while deleting subscription."
                                                         });
                    done();
                });
            };

            [database executeOperation:operation];
        });
    });

    describe(@"when there exists device id", ^{
        __block ODDeleteSubscriptionsOperation *operation;

        beforeEach(^{
            id odDefaultsMock = OCMClassMock(ODDefaults.class);
            OCMStub([odDefaultsMock sharedDefaults]).andReturn(odDefaultsMock);
            OCMStub([odDefaultsMock deviceID]).andReturn(@"EXISTING_DEVICE_ID");

            operation = [[ODDeleteSubscriptionsOperation alloc] initWithSubscriptionIDsToDelete:@[]];
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

