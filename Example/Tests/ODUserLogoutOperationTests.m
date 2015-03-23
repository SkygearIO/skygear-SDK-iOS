//
//  ODUserLogoutOperationTests.m
//  ODKit
//
//  Created by Patrick Cheung on 2/3/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(ODUserLogoutOperation)

describe(@"logout", ^{
    __block ODContainer *container = nil;
    
    beforeEach(^{
        container = [[ODContainer alloc] init];
        [container updateWithUserRecordID:[[ODUserRecordID alloc] initWithRecordType:@"user" name:@"USER_ID"]
                              accessToken:[[ODAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];
    });
    
    it(@"make ODRequest", ^{
        ODUserLogoutOperation *operation = [[ODUserLogoutOperation alloc] init];
        operation.container = container;
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"auth:logout");
        expect(request.accessToken).to.equal(container.currentAccessToken);
    });
    
    it(@"make request", ^{
        ODUserLogoutOperation *operation = [[ODUserLogoutOperation alloc] init];
        
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
        ODUserLogoutOperation *operation = [[ODUserLogoutOperation alloc] init];
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
