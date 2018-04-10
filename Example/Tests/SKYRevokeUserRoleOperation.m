//
//  SKYRevokeUserRoleOperation.m
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

SpecBegin(SKYRevokeUserRoleOperation)

    describe(@"Revoke User Role Operation", ^{
        NSString *apiKey = @"CORRECT_KEY";
        NSString *currentUserID = @"CORRECT_USER_ID";
        NSString *token = @"CORRECT_TOKEN";

        NSString *developerRoleName = @"Developer";
        NSString *testerRoleName = @"Tester";

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
            SKYRevokeUserRoleOperation *operation = [SKYRevokeUserRoleOperation
                operationWithUserIDs:@[ user1, user2, user3 ]
                           roleNames:@[ developerRoleName, testerRoleName ]];

            [operation setContainer:container];
            [operation makeURLRequestWithError:nil];

            SKYRequest *request = operation.request;
            expect(request.action).to.equal(@"role:revoke");
            expect(request.accessToken.tokenString).to.equal(token);

            expect(request.payload[@"users"]).to.equal(@[ @"user1", @"user2", @"user3" ]);
            expect(request.payload[@"roles"]).to.equal(@[ @"Developer", @"Tester" ]);
        });

        it(@"should handle success response correctly", ^{
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *response = @{@"result" : @"OK"};
                    return [OHHTTPStubsResponse responseWithJSONObject:response
                                                            statusCode:200
                                                               headers:nil];
                }];

            SKYRevokeUserRoleOperation *operation = [SKYRevokeUserRoleOperation
                operationWithUserIDs:@[ user1, user2, user3 ]
                           roleNames:@[ developerRoleName, testerRoleName ]];

            [operation setContainer:container];

            waitUntil(^(DoneCallback done) {
                operation.revokeUserRoleCompletionBlock =
                    ^(NSArray<NSString *> *userIDs, NSError *error) {
                        expect(error).to.beNil();
                        expect(userIDs).to.haveCountOf(3);
                        expect(userIDs).to.contain(@"user1");
                        expect(userIDs).to.contain(@"user2");
                        expect(userIDs).to.contain(@"user3");

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
