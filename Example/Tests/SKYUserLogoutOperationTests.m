//
//  SKYUserLogoutOperationTests.m
//  SkyKit
//
//  Created by Patrick Cheung on 2/3/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SkyKit/SkyKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(SKYUserLogoutOperation)

describe(@"logout", ^{
    __block SKYContainer *container = nil;
    
    beforeEach(^{
        container = [[SKYContainer alloc] init];
        [container updateWithUserRecordID:[SKYUserRecordID recordIDWithUsername:@"USER_ID"]
                              accessToken:[[SKYAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];
    });
    
    it(@"make SKYRequest", ^{
        SKYUserLogoutOperation *operation = [[SKYUserLogoutOperation alloc] init];
        operation.container = container;
        [operation prepareForRequest];
        SKYRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([SKYRequest class]);
        expect(request.action).to.equal(@"auth:logout");
        expect(request.accessToken).to.equal(container.currentAccessToken);
    });
    
    it(@"make request", ^{
        SKYUserLogoutOperation *operation = [[SKYUserLogoutOperation alloc] init];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         };
            NSData *payload = [NSJSONSerialization dataWithJSONObject:@{@"result": parameters}
                                                              options:0
                                                                error:nil];
            
            return [OHHTTPStubsResponse responseWithData:payload
                                              statusCode:200
                                                 headers:@{}];
        }];
        
        waitUntil(^(DoneCallback done) {
            operation.logoutCompletionBlock = ^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    done();
                });
            };
            
            [container addOperation:operation];
        });
    });
    
    it(@"pass error", ^{
        SKYUserLogoutOperation *operation = [[SKYUserLogoutOperation alloc] init];
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:nil]];
        }];
        
        waitUntil(^(DoneCallback done) {
            operation.logoutCompletionBlock = ^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(error).toNot.beNil();
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
