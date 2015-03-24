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

SpecBegin(ODRegisterDeviceOperation)

describe(@"register", ^{
    __block ODContainer *container = nil;
    
    beforeEach(^{
        container = [[ODContainer alloc] init];
        [container updateWithUserRecordID:[[ODUserRecordID alloc] initWithRecordType:@"user" name:@"USER_ID"]
                              accessToken:[[ODAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];
    });
    
    it(@"new device request", ^{
        ODRegisterDeviceOperation *operation = [[ODRegisterDeviceOperation alloc] initWithDeviceToken:@"DEVICE_TOKEN"];
        operation.container = container;
        [operation prepareForRequest];
        
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"device:register");
        expect(request.accessToken).to.equal(container.currentAccessToken);
        expect(request.payload[@"device_token"]).to.equal(@"DEVICE_TOKEN");
        expect(request.payload[@"id"]).to.beNil();
    });
    
    it(@"update device request", ^{
        ODRegisterDeviceOperation *operation = [[ODRegisterDeviceOperation alloc] initWithDeviceToken:@"DEVICE_TOKEN"];
        operation.deviceID = @"DEVICE_ID";
        operation.container = container;
        [operation prepareForRequest];
        
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"device:register");
        expect(request.accessToken).to.equal(container.currentAccessToken);
        expect(request.payload[@"device_token"]).to.equal(@"DEVICE_TOKEN");
        expect(request.payload[@"id"]).to.equal(@"DEVICE_ID");
    });
    
    it(@"new device response", ^{
        ODRegisterDeviceOperation *operation = [[ODRegisterDeviceOperation alloc] initWithDeviceToken:@"DEVICE_TOKEN"];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         @"id": @"DEVICE_ID",
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
                    done();
                });
            };
            [container addOperation:operation];
        });
    });
    
    it(@"pass error", ^{
        ODRegisterDeviceOperation *operation = [[ODRegisterDeviceOperation alloc] initWithDeviceToken:@"DEVICE_TOKEN"];
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
    
    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });
});

SpecEnd
