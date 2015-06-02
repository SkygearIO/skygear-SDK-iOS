//
//  ODDiscoverUsersOperationTests.m
//  ODKit
//
//  Created by Kenji Pa on 1/6/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <ODKit/ODKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(ODDiscoverUsersOperation)

describe(@"discover", ^{
    __block ODContainer *container = nil;

    beforeEach(^{
        container = [[ODContainer alloc] init];
        [container updateWithUserRecordID:[ODUserRecordID recordIDWithUsername:@"USER_ID"] accessToken:[[ODAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];
    });

    it(@"multiple emails", ^{
        ODDiscoverUsersOperation *operation = [[ODDiscoverUsersOperation alloc] initWithEmails:@[@"john.doe@example.com", @"jane.doe@example.com"]];
        operation.container = container;
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"user:query");
        expect(request.accessToken.tokenString).to.equal(@"ACCESS_TOKEN");
        expect(request.payload).to.equal(@{
                                           @"emails": @[@"john.doe@example.com", @"jane.doe@example.com"],
                                           });
    });

    it(@"make request", ^{
        ODDiscoverUsersOperation *operation = [[ODDiscoverUsersOperation alloc] initWithEmails:@[@"john.doe@example.com", @"jane.doe@example.com"]];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         @"result": @[
                                                 @{
                                                     @"id": @"user0",
                                                     @"type": @"user",
                                                     @"data": @{
                                                             @"_id": @"user0",
                                                             @"email": @"john.doe@example.com",
                                                             },
                                                     },
                                                 @{
                                                     @"id": @"user1",
                                                     @"type": @"user",
                                                     @"data": @{
                                                             @"_id": @"user1",
                                                             @"email": @"jane.doe@example.com",
                                                             },
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
            operation.discoverUserCompletionBlock = ^(NSArray *users, NSArray *emailsNotFound, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(users).to.haveCountOf(2);
                    expect([users[0] username]).to.equal(@"user0");
                    expect([users[1] username]).to.equal(@"user1");
                    expect(emailsNotFound).to.haveCountOf(0);
                    expect(operationError).to.beNil();
                    done();
                });
            };

            [container addOperation:operation];
        });
    });

    it(@"not found", ^{
        ODDiscoverUsersOperation *operation = [[ODDiscoverUsersOperation alloc] initWithEmails:@[@"john.doe@example.com", @"jane.doe@example.com"]];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         @"result": @[
                                                 @{
                                                     @"id": @"user0",
                                                     @"type": @"user",
                                                     @"data": @{
                                                             @"_id": @"user0",
                                                             @"email": @"john.doe@example.com",
                                                             },
                                                     },
                                                 @{
                                                     @"id": @"extraID",
                                                     @"type": @"user",
                                                     @"data": @{
                                                             @"_id": @"extraID",
                                                             @"email": @"extra@example.com",
                                                             },
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
            operation.discoverUserCompletionBlock = ^(NSArray *users, NSArray *emailsNotFound, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(users).to.haveCountOf(1);
                    expect([users[0] username]).to.equal(@"user0");
                    expect(emailsNotFound).to.equal(@[@"jane.doe@example.com"]);
                    expect(operationError).to.beNil();
                    done();
                });
            };

            [container addOperation:operation];
        });
    });
});

SpecEnd
