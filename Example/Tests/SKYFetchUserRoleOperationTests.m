//
//  SKYGetUserRoleOperationTests.m
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
#import <SKYKit/SKYKit.h>

SpecBegin(SKYFetchUserRoleOperation)

    describe(@"Fetch User Role Operation", ^{
        NSString *apiKey = @"CORRECT_KEY";
        NSString *currentUserID = @"CORRECT_USER_ID";
        NSString *token = @"CORRECT_TOKEN";

        NSString *user1 = @"user1";
        NSString *user2 = @"user2";
        NSString *user3 = @"user3";

        __block SKYContainer *container;

        beforeEach(^{
            container = [SKYContainer testContainer];
            [container.auth
                updateWithUserRecordID:currentUserID
                           accessToken:[[SKYAccessToken alloc] initWithTokenString:token]];
        });

        it(@"should create SKYRequest correctly", ^{
            SKYFetchUserRoleOperation *operation =
                [SKYFetchUserRoleOperation operationWithUserIDs:@[ user1, user2, user3 ]];

            [operation setContainer:container];
            [operation prepareForRequest];

            SKYRequest *request = operation.request;
            expect(request.action).to.equal(@"role:get");
            expect(request.accessToken.tokenString).to.equal(token);

            expect(request.payload[@"users"]).to.equal(@[ @"user1", @"user2", @"user3" ]);
        });

        it(@"should handle success response correctly", ^{
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *response = @{
                        @"result" : @{
                            @"user1" : @[ @"Developer" ],
                            @"user2" : @[ @"Admin", @"Tester" ],
                            @"user3" : @[],
                        },
                    };
                    return [OHHTTPStubsResponse responseWithJSONObject:response
                                                            statusCode:200
                                                               headers:nil];
                }];

            SKYFetchUserRoleOperation *operation =
                [SKYFetchUserRoleOperation operationWithUserIDs:@[ user1, user2, user3 ]];

            [operation setContainer:container];

            waitUntil(^(DoneCallback done) {
                operation.fetchUserRoleCompletionBlock =
                    ^(NSDictionary<NSString *, NSString *> *userRoles, NSError *error) {
                        expect(error).to.beNil();
                        expect(userRoles[@"user1"]).to.haveCountOf(1);
                        expect(userRoles[@"user1"]).to.contain(@"Developer");
                        expect(userRoles[@"user2"]).to.haveCountOf(2);
                        expect(userRoles[@"user2"]).to.contain(@"Admin");
                        expect(userRoles[@"user2"]).to.contain(@"Tester");
                        expect(userRoles[@"user3"]).to.haveCountOf(0);
                        done();
                    };

                [container addOperation:operation];
            });
        });

        afterEach(^{
            [OHHTTPStubs removeAllStubs];
        });
    });

SpecEnd
