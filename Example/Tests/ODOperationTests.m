//
//  ODOperationTests.m
//  ODKit
//
//  Created by Patrick Cheung on 25/2/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(ODOperation)

describe(@"request", ^{
    __block ODContainer *container = nil;
    
    beforeEach(^{
        container = [[ODContainer alloc] init];
        [container updateWithUserRecordID:[ODUserRecordID recordIDWithUsername:@"USER_ID"]
                              accessToken:[[ODAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];
    });

    it(@"make http request", ^{
        NSString *action = @"auth:login";
        NSDictionary *payload = @{};
        
        ODRequest *request = [[ODRequest alloc] initWithAction:action payload:payload];
        ODOperation *operation = [[ODOperation alloc] initWithRequest:request];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            expect(operation.executing).to.equal(YES);
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:@{}
                                                           options:0
                                                             error:nil];
            
            return [[OHHTTPStubsResponse alloc] initWithData:data
                                                  statusCode:200
                                                     headers:@{}];
        }];
        
        waitUntil(^(DoneCallback done) {
            __block typeof(operation) blockOp = operation;
            operation.completionBlock = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(blockOp.finished).to.equal(YES);
                    expect(blockOp.error).to.beNil();
                    done();
                });
            };
            [container addOperation:operation];
        });
    });
    
    it(@"handle NSError", ^{
        NSString *action = @"auth:login";
        NSDictionary *payload = @{};
        
        ODRequest *request = [[ODRequest alloc] initWithAction:action payload:payload];
        ODOperation *operation = [[ODOperation alloc] initWithRequest:request];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            expect(operation.executing).to.equal(YES);
            
            NSError *networkError = [NSError errorWithDomain:NSURLErrorDomain
                                                        code:-1001
                                                    userInfo:@{
                                                               NSLocalizedDescriptionKey: @"The operation couldn’t be completed.",
                                                               NSURLErrorFailingURLStringErrorKey: request.URL
                                                               }];
            return [[OHHTTPStubsResponse alloc] initWithError:networkError];
        }];
        
        waitUntil(^(DoneCallback done) {
            __block typeof(operation) blockOp = operation;
            operation.completionBlock = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(blockOp.finished).to.equal(YES);
                    expect([blockOp.error class]).to.beSubclassOf([NSError class]);
                    expect(blockOp.error.code).to.equal(-1001);
                    done();
                });
            };
            [container addOperation:operation];
        });
    });
    
    it(@"handle non json response", ^{
        NSString *action = @"auth:login";
        NSDictionary *payload = @{};
        
        ODRequest *request = [[ODRequest alloc] initWithAction:action payload:payload];
        ODOperation *operation = [[ODOperation alloc] initWithRequest:request];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            expect(operation.executing).to.equal(YES);
            
            return [[OHHTTPStubsResponse alloc] initWithData:[@"INVALID DATA" dataUsingEncoding:NSUTF8StringEncoding]
                                                  statusCode:200
                                                     headers:@{}];
        }];
        
        waitUntil(^(DoneCallback done) {
            __block typeof(operation) blockOp = operation;
            operation.completionBlock = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(blockOp.finished).to.equal(YES);
                    expect([blockOp.error class]).to.beSubclassOf([NSError class]);
                    expect([(NSError *)[blockOp.error userInfo][NSUnderlyingErrorKey] code]).to.equal(3840);
                    done();
                });
            };
            [container addOperation:operation];
        });
    });
    
    it(@"handle array JSON response", ^{
        NSString *action = @"auth:login";
        NSDictionary *payload = @{};
        
        ODRequest *request = [[ODRequest alloc] initWithAction:action payload:payload];
        ODOperation *operation = [[ODOperation alloc] initWithRequest:request];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            expect(operation.executing).to.equal(YES);
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:@[]
                                                           options:0
                                                             error:nil];
            
            return [[OHHTTPStubsResponse alloc] initWithData:data
                                                  statusCode:200
                                                     headers:@{}];
        }];
        
        waitUntil(^(DoneCallback done) {
            __block typeof(operation) blockOp = operation;
            operation.completionBlock = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(blockOp.finished).to.equal(YES);
                    expect([blockOp.error class]).to.beSubclassOf([NSError class]);
                    // FIXME: More concrete checks of the error?
                    done();
                });
            };
            [container addOperation:operation];
        });
    });
    
    it(@"handle 400", ^{
        NSString *action = @"auth:login";
        NSDictionary *payload = @{};
        
        ODRequest *request = [[ODRequest alloc] initWithAction:action payload:payload];
        ODOperation *operation = [[ODOperation alloc] initWithRequest:request];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            expect(operation.executing).to.equal(YES);
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:@{
                                                                     @"error": @{
                                                                             @"message": @"Unable to login.",
                                                                             @"type": @"LoginError",
                                                                             @"code": @100,
                                                                             @"error": @{
                                                                                     @"username": @"user@example.com",
                                                                                     },
                                                                             }}
                                                           options:0
                                                             error:nil];
            
            return [[OHHTTPStubsResponse alloc] initWithData:data
                                                  statusCode:400
                                                     headers:@{}];
        }];
        
        waitUntil(^(DoneCallback done) {
            __block typeof(operation) blockOp = operation;
            operation.completionBlock = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(blockOp.finished).to.equal(YES);
                    NSError *error = blockOp.error;
                    expect([error class]).to.beSubclassOf([NSError class]);
                    expect(error.userInfo[ODOperationErrorHTTPStatusCodeKey]).to.equal(@(400));
                    expect([error ODErrorType]).to.equal(@"LoginError");
                    done();
                });
            };
            [container addOperation:operation];
        });
    });
    
    it(@"handle 500", ^{
        NSString *action = @"auth:login";
        NSDictionary *payload = @{};
        
        ODRequest *request = [[ODRequest alloc] initWithAction:action payload:payload];
        ODOperation *operation = [[ODOperation alloc] initWithRequest:request];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            expect(operation.executing).to.equal(YES);
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:@{
                                                                     @"error": @{
                                                                             @"message": @"Unable to login.",
                                                                             @"type": @"LoginError",
                                                                             @"code": @100,
                                                                             @"error": @{
                                                                                     @"username": @"user@example.com",
                                                                                     },
                                                                             }}
                                                           options:0
                                                             error:nil];
            
            return [[OHHTTPStubsResponse alloc] initWithData:data
                                                  statusCode:500
                                                     headers:@{}];
        }];
        
        waitUntil(^(DoneCallback done) {
            __block typeof(operation) blockOp = operation;
            operation.completionBlock = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(blockOp.finished).to.equal(YES);
                    NSError *error = blockOp.error;
                    expect([error class]).to.beSubclassOf([NSError class]);
                    expect(error.userInfo[ODOperationErrorHTTPStatusCodeKey]).to.equal(@(500));
                    expect([error ODErrorType]).to.equal(@"LoginError");
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
