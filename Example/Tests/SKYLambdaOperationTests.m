//
//  SKYLambdaOperationTests.m
//  SKYKit
//
//  Copyright 2015 Oursky Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <SKYKit/SKYKit.h>

SpecBegin(SKYLambdaOperation)

    describe(@"lambda", ^{
        __block SKYContainer *container = nil;

        beforeEach(^{
            container = [SKYContainer testContainer];
            [container.auth updateWithUserRecordID:@"USER_ID"
                                       accessToken:[[SKYAccessToken alloc]
                                                       initWithTokenString:@"ACCESS_TOKEN"]];
        });

        it(@"calls lambda with array args", ^{
            NSArray *args = @[ @"bob" ];
            SKYLambdaOperation *operation =
                [SKYLambdaOperation operationWithAction:@"hello:world" arrayArguments:args];
            operation.container = container;
            [operation makeURLRequestWithError:nil];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"hello:world");
            expect(request.APIKey).to.equal(container.APIKey);
            expect(request.accessToken).to.equal(container.auth.currentAccessToken);
            expect(request.payload[@"args"]).to.equal(args);
        });

        it(@"calls lambda with dict args", ^{
            NSDictionary *args = @{@"name" : @"bob"};
            SKYLambdaOperation *operation =
                [SKYLambdaOperation operationWithAction:@"hello:world" dictionaryArguments:args];
            operation.container = container;
            [operation makeURLRequestWithError:nil];
            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"hello:world");
            expect(request.APIKey).to.equal(container.APIKey);
            expect(request.accessToken).to.equal(container.auth.currentAccessToken);
            expect(request.payload[@"args"]).to.equal(args);
        });

        it(@"make request", ^{
            NSDictionary *args = @{@"name" : @"bob"};
            SKYLambdaOperation *operation =
                [SKYLambdaOperation operationWithAction:@"hello:world" dictionaryArguments:args];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *parameters = @{
                        @"request_id" : @"REQUEST_ID",
                        @"result" : @{
                            @"message" : @"hello bob",
                        }
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
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
            NSDictionary *args = @{@"name" : @"bob"};
            SKYLambdaOperation *operation =
                [SKYLambdaOperation operationWithAction:@"hello:world" dictionaryArguments:args];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    return [OHHTTPStubsResponse
                        responseWithError:[NSError errorWithDomain:NSURLErrorDomain
                                                              code:0
                                                          userInfo:nil]];
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
