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
    it(@"make ODRequest", ^{
        ODUserLogoutOperation *operation = [[ODUserLogoutOperation alloc] init];
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"auth:logout");
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
            
            [[[NSOperationQueue alloc] init] addOperation:operation];
        });
    });
    
    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });
    
});

SpecEnd
