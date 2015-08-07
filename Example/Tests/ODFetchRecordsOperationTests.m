//
//  ODFetchRecordsOperationTests.m
//  ODKit
//
//  Created by Patrick Cheung on 26/2/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(ODFetchRecordsOperation)

describe(@"fetch", ^{
    __block ODContainer *container = nil;

    beforeEach(^{
        container = [[ODContainer alloc] init];
        [container updateWithUserRecordID:[ODUserRecordID recordIDWithUsername:@"USER_ID"]
                              accessToken:[[ODAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];
    });

    it(@"calls lambda with array args", ^{
        NSArray *args = @[@"bob"];
        ODLambdaOperation *operation = [ODLambdaOperation operationWithAction:@"hello:world"
                                                               arrayArguments:args];
        operation.container = container;
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"hello:world");
        expect(request.accessToken).to.equal(container.currentAccessToken);
        expect(request.payload[@"args"]).to.equal(args);
    });

    it(@"calls lambda with dict args", ^{
        NSDictionary *args = @{@"name": @"bob"};
        ODLambdaOperation *operation = [ODLambdaOperation operationWithAction:@"hello:world"
                                                          dictionaryArguments:args];
        operation.container = container;
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"hello:world");
        expect(request.accessToken).to.equal(container.currentAccessToken);
        expect(request.payload[@"args"]).to.equal(args);
    });

    it(@"make request", ^{
        NSDictionary *args = @{@"name": @"bob"};
        ODLambdaOperation *operation = [ODLambdaOperation operationWithAction:@"hello:world"
                                                          dictionaryArguments:args];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         @"request_id": @"REQUEST_ID",
                                         @"result": @{
                                                 @"message": @"hello bob",
                                                 }
                                         };
            NSData *payload = [NSJSONSerialization dataWithJSONObject:parameters
                                                              options:0
                                                                error:nil];

            return [OHHTTPStubsResponse responseWithData:payload
                                              statusCode:200
                                                 headers:@{}];
        }];

        waitUntil(^(DoneCallback done) {
            operation.lambdaCompletionBlock = ^(NSDictionary *result, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect([result class]).to.beSubclassOf([NSDictionary class]);
                    expect(result[@"message"]).to.equal(@"hello bob");
                    done();
                });
            };

            [container addOperation:operation];
        });
    });

    it(@"pass error", ^{
        NSDictionary *args = @{@"name": @"bob"};
        ODLambdaOperation *operation = [ODLambdaOperation operationWithAction:@"hello:world"
                                                             dictionaryArguments:args];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:nil]];
        }];

        waitUntil(^(DoneCallback done) {
            operation.lambdaCompletionBlock = ^(NSDictionary *result, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(operationError).toNot.beNil();
                    done();
                });
            };

            [container addOperation:operation];
        });
    });

    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });
});

SpecEnd
