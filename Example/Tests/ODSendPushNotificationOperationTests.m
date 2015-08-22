//
//  ODSendPushNotificationOperationTests.m
//  ODKit
//
//  Created by atwork on 15/8/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "ODNotificationInfo.h"

SpecBegin(ODSendPushNotificationOperation)

describe(@"send push", ^{
    __block ODContainer *container = nil;
    ODNotificationInfo *notificationInfo = [ODNotificationInfo notificationInfo];
    notificationInfo.alertBody = @"Hello World!";
    NSDictionary *expectedNotificationPayload = @{@"aps": @{@"alert": @{@"body": @"Hello World!"}}};
    
    beforeEach(^{
        container = [[ODContainer alloc] init];
        [container updateWithUserRecordID:[ODUserRecordID recordIDWithUsername:@"USER_ID"]
                              accessToken:[[ODAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];
    });
    
    it(@"send to device", ^{
        ODSendPushNotificationOperation *operation = [ODSendPushNotificationOperation operationWithNotificationInfo:notificationInfo deviceIDsToSend:@[ @"johndoe" ]];
        operation.container = container;
        [operation prepareForRequest];
        
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.APIKey).to.equal(container.APIKey);
        expect(request.action).to.equal(@"push:device");
        expect(request.payload).to.equal(@{
                                           @"device_ids": @[@"johndoe"],
                                           @"notification": expectedNotificationPayload,
                                           });
    });
    
    it(@"send to user", ^{
        ODSendPushNotificationOperation *operation = [ODSendPushNotificationOperation operationWithNotificationInfo:notificationInfo userIDsToSend:@[ @"johndoe" ]];
        operation.container = container;
        [operation prepareForRequest];
        
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.APIKey).to.equal(container.APIKey);
        expect(request.action).to.equal(@"push:user");
        expect(request.payload).to.equal(@{
                                           @"user_ids": @[@"johndoe"],
                                           @"notification": expectedNotificationPayload,
                                           });
    });
    
    it(@"send multiple", ^{
        ODSendPushNotificationOperation *operation = [ODSendPushNotificationOperation operationWithNotificationInfo:notificationInfo userIDsToSend:@[ @"johndoe", @"janedoe" ]];
        operation.container = container;
        [operation prepareForRequest];
        
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.APIKey).to.equal(container.APIKey);
        expect(request.action).to.equal(@"push:user");
        expect(request.payload).to.equal(@{
                                           @"user_ids": @[@"johndoe", @"janedoe"],
                                           @"notification": expectedNotificationPayload,
                                           });
    });
    
    it(@"make request", ^{
        ODSendPushNotificationOperation *operation = [ODSendPushNotificationOperation operationWithNotificationInfo:notificationInfo userIDsToSend:@[ @"johndoe", @"janedoe" ]];
        operation.container = container;
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         @"request_id": @"REQUEST_ID",
                                         @"result": @[
                                                 @{
                                                     @"_id": @"johndoe",
                                                     },
                                                 @{
                                                     @"_id": @"janedoe",
                                                     @"_type": @"error",
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
            __block NSMutableArray *processedIDs = [NSMutableArray array];
            operation.perSendCompletionHandler = ^(NSString *stringID, NSError *error) {
                [processedIDs addObject:stringID];
                if ([stringID isEqualToString:@"johndoe"]) {
                    expect(error).to.beNil();
                } else if ([stringID isEqualToString:@"janedoe"]) {
                    expect([error class]).to.beSubclassOf([NSError class]);
                }
            };
            operation.sendCompletionHandler = ^(NSArray *stringIDs, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(stringIDs).to.equal(@[@"johndoe"]);
                    expect(processedIDs).to.equal(@[@"johndoe", @"janedoe"]);
                    expect([error class]).to.beSubclassOf([NSError class]);
                    expect(error.code).to.equal(@(ODErrorPartialFailure));
                    done();
                });
            };
            
            [container addOperation:operation];
        });
    });
    
    it(@"pass error", ^{
        ODSendPushNotificationOperation *operation = [ODSendPushNotificationOperation operationWithNotificationInfo:notificationInfo userIDsToSend:@[ @"johndoe", @"janedoe" ]];
        operation.container = container;
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:nil]];
        }];
        
        waitUntil(^(DoneCallback done) {
            operation.sendCompletionHandler = ^(NSArray *stringIDs, NSError *operationError) {
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
