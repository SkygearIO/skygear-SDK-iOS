//
//  SKYAuthContainerSSOTests.m
//  SKYKit
//
//  Copyright 2017 Oursky Ltd.
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

#import "SKYHexer.h"

#import "SKYAuthContainer+SSO.h"
#import "SKYAuthContainer_Private.h"

SpecBegin(SKYAuthContainerSSO)

    describe(@"user login with custom token", ^{
        __block SKYContainer *container = nil;
        __block void (^assertLoggedIn)(NSString *, NSError *) =
            ^(NSString *userRecordID, NSError *error) {
                expect(container.auth.currentUserRecordID).to.equal(userRecordID);
                expect(container.auth.currentUser.dictionary[@"username"]).to.equal(@"john.doe");
                expect(container.auth.currentUser.dictionary[@"email"])
                    .to.equal(@"john.doe@example.com");
                expect(error).to.beNil();
                expect(userRecordID).to.equal(@"UUID");
                expect(container.auth.currentAccessToken.tokenString).to.equal(@"ACCESS_TOKEN");
            };

        beforeEach(^{
            container = [[SKYContainer alloc] init];
            container.defaultTimeoutInterval = 1.0;
            [container configureWithAPIKey:@"API_KEY"];
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                NSString *path = [[request URL] path];
                return [path isEqualToString:@"/sso/custom_token/login"];
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    expect(request.timeoutInterval).to.equal(1.0);
                    NSDictionary *parameters = @{
                        @"user_id" : @"UUID",
                        @"access_token" : @"ACCESS_TOKEN",
                        @"profile" : @{
                            @"_id" : @"user/UUID",
                            @"_access" : [NSNull null],
                            @"username" : @"john.doe",
                            @"email" : @"john.doe@example.com",
                        },
                    };
                    NSData *payload =
                        [NSJSONSerialization dataWithJSONObject:@{@"result" : parameters}
                                                        options:0
                                                          error:nil];

                    return
                        [OHHTTPStubsResponse responseWithData:payload statusCode:200 headers:@{}];
                }];
        });

        it(@"login with custom token", ^{
            waitUntil(^(DoneCallback done) {
                [container.auth loginWithCustomToken:@"eyXXX"
                                   completionHandler:^(SKYRecord *user, NSError *error) {
                                       assertLoggedIn(user.recordID.recordName, error);
                                       done();
                                   }];
            });
        });

        afterEach(^{
            [OHHTTPStubs removeAllStubs];

            NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
            [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        });
    });

SpecEnd
