//
//  ODRegisterDeviceOperationTests.m
//  ODKit
//
//  Created by atwork on 24/3/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "ODHexer.h"

SpecBegin(ODRegisterDeviceOperation)

describe(@"register", ^{
    __block ODContainer *container = nil;
    __block id odDefaultsMock = nil;

    beforeEach(^{
        container = [[ODContainer alloc] init];
        [container updateWithUserRecordID:[[ODUserRecordID alloc] initWithRecordType:@"user" name:@"USER_ID"]
                              accessToken:[[ODAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];

        odDefaultsMock = OCMClassMock(ODDefaults.class);
        OCMStub([odDefaultsMock sharedDefaults]).andReturn(odDefaultsMock);
    });
    
    it(@"new device request", ^{
        ODRegisterDeviceOperation *operation = [[ODRegisterDeviceOperation alloc] initWithDeviceToken:[ODHexer dataWithHexString:@"abcdef1234567890"]];
        operation.container = container;
        [operation prepareForRequest];
        
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"device:register");
        expect(request.accessToken).to.equal(container.currentAccessToken);
        expect(request.payload[@"device_token"]).to.equal(@"abcdef1234567890");
        expect(request.payload[@"id"]).to.beNil();
    });
    
    it(@"update device request", ^{
        ODRegisterDeviceOperation *operation = [[ODRegisterDeviceOperation alloc] initWithDeviceToken:[ODHexer dataWithHexString:@"abcdef1234567890"]];
        operation.deviceID = @"DEVICE_ID";
        operation.container = container;
        [operation prepareForRequest];
        
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"device:register");
        expect(request.accessToken).to.equal(container.currentAccessToken);
        expect(request.payload[@"device_token"]).to.equal(@"abcdef1234567890");
        expect(request.payload[@"id"]).to.equal(@"DEVICE_ID");
    });
    
    it(@"new device response", ^{
        ODRegisterDeviceOperation *operation = [[ODRegisterDeviceOperation alloc] initWithDeviceToken:[ODHexer dataWithHexString:@"abcdef1234567890"]];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         @"result": @{
                                             @"id": @"DEVICE_ID",
                                             },
                                         };
            NSData *payload = [NSJSONSerialization dataWithJSONObject:parameters
                                                              options:0
                                                                error:nil];
            
            return [OHHTTPStubsResponse responseWithData:payload
                                              statusCode:200
                                                 headers:@{}];
        }];
        
        waitUntil(^(DoneCallback done) {
            operation.registerCompletionBlock = ^(NSString *deviceID, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(deviceID).to.equal(@"DEVICE_ID");
                    OCMVerify([odDefaultsMock setDeviceID:@"DEVICE_ID"]);
                    done();
                });
            };
            [container addOperation:operation];
        });
    });

    it(@"error with response without id", ^{
        ODRegisterDeviceOperation *operation = [[ODRegisterDeviceOperation alloc] initWithDeviceToken:[ODHexer dataWithHexString:@"abcdef1234567890"]];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         @"result": @{},
                                         };
            NSData *payload = [NSJSONSerialization dataWithJSONObject:parameters
                                                              options:0
                                                                error:nil];

            return [OHHTTPStubsResponse responseWithData:payload
                                              statusCode:200
                                                 headers:@{}];
        }];

        waitUntil(^(DoneCallback done) {
            operation.registerCompletionBlock = ^(NSString *deviceID, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(operationError).toNot.beNil();
                    done();
                });
            };
            [container addOperation:operation];
        });
    });

    it(@"pass error", ^{
        ODRegisterDeviceOperation *operation = [[ODRegisterDeviceOperation alloc] initWithDeviceToken:[ODHexer dataWithHexString:@"abcdef1234567890"]];
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:nil]];
        }];
        
        waitUntil(^(DoneCallback done) {
            operation.registerCompletionBlock = ^(NSString *deviceID, NSError *operationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(operationError).toNot.beNil();
                    done();
                });
            };
            [container addOperation:operation];
        });
    });

    describe(@"when there exists device id", ^{
        beforeEach(^{
            OCMStub([odDefaultsMock deviceID]).andReturn(@"EXISTING_DEVICE_ID");
        });

        it(@"request with device id", ^{
            ODRegisterDeviceOperation *operation = [[ODRegisterDeviceOperation alloc] initWithDeviceToken:[ODHexer dataWithHexString:@"abcdef1234567890"]];
            operation.container = container;
            [operation prepareForRequest];
            expect(operation.request.payload[@"id"]).to.equal(@"EXISTING_DEVICE_ID");
        });

        it(@"reqeust be overriden by deviceID property", ^{
            ODRegisterDeviceOperation *operation = [[ODRegisterDeviceOperation alloc] initWithDeviceToken:[ODHexer dataWithHexString:@"abcdef1234567890"]];
            operation.container = container;
            operation.deviceID = @"ASSIGNED_DEVICE_ID";
            [operation prepareForRequest];
            expect(operation.request.payload[@"id"]).to.equal(@"ASSIGNED_DEVICE_ID");
        });

        it(@"update device id from response", ^{
            ODRegisterDeviceOperation *operation = [[ODRegisterDeviceOperation alloc] initWithDeviceToken:[ODHexer dataWithHexString:@"abcdef1234567890"]];

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSDictionary *parameters = @{
                                             @"result": @{
                                                     @"id": @"BRAND_NEW_DEVICE_ID",
                                                     },
                                             };
                NSData *payload = [NSJSONSerialization dataWithJSONObject:parameters
                                                                  options:0
                                                                    error:nil];

                return [OHHTTPStubsResponse responseWithData:payload
                                                  statusCode:200
                                                     headers:@{}];
            }];

            waitUntil(^(DoneCallback done) {
                operation.registerCompletionBlock = ^(NSString *deviceID, NSError *operationError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(deviceID).to.equal(@"BRAND_NEW_DEVICE_ID");
                        OCMVerify([odDefaultsMock setDeviceID:@"BRAND_NEW_DEVICE_ID"]);
                        done();
                    });
                };
                [container addOperation:operation];
            });
        });
    });

    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });
});

SpecEnd
