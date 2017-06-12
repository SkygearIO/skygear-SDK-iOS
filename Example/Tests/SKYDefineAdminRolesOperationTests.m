//
//  SKYDefineAdminRolesOperationTests.m
//  SKYKit
//
//  Copyright 2015 Oursky Ltd.
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

SpecBegin(SKYDefineAdminRolesOperation)

    describe(@"Define Admin Role Operation", ^{
        NSString *apiKey = @"CORRECT_KEY";
        NSString *currentUserID = @"CORRECT_USER_ID";
        NSString *token = @"CORRECT_TOKEN";

        NSString *developerRoleName = @"Developer";
        NSString *testerRoleName = @"Tester";
        NSString *pmRoleName = @"Project Manager";

        NSArray<SKYRole *> *roles = @[
            [SKYRole roleWithName:developerRoleName], [SKYRole roleWithName:testerRoleName],
            [SKYRole roleWithName:pmRoleName]
        ];

        __block SKYContainer *container = nil;

        beforeEach(^{
            container = [[SKYContainer alloc] init];
            [container configureWithAPIKey:apiKey];
            [container.auth
                updateWithUserRecordID:currentUserID
                           accessToken:[[SKYAccessToken alloc] initWithTokenString:token]];
        });

        it(@"should create SKYRequest correctly", ^{
            SKYDefineAdminRolesOperation *operation =
                [SKYDefineAdminRolesOperation operationWithRoles:roles];

            [operation setContainer:container];
            [operation prepareForRequest];

            SKYRequest *request = operation.request;
            expect(request.action).to.equal(@"role:admin");
            expect(request.accessToken.tokenString).to.equal(token);
            expect(request.payload).to.equal(@{
                @"roles" : @[ developerRoleName, testerRoleName, pmRoleName ]
            });
        });

        it(@"should handle success response correctly", ^{
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *response = @{
                        @"result" : @{@"roles" : @[ developerRoleName, testerRoleName, pmRoleName ]}
                    };
                    return [OHHTTPStubsResponse responseWithJSONObject:response
                                                            statusCode:200
                                                               headers:nil];
                }];

            SKYDefineAdminRolesOperation *operation =
                [SKYDefineAdminRolesOperation operationWithRoles:roles];

            [operation setContainer:container];

            waitUntil(^(DoneCallback done) {
                operation.defineAdminRolesCompletionBlock =
                    ^(NSArray<SKYRole *> *roles, NSError *error) {
                        expect(roles.count).to.equal(3);
                        expect(roles).to.contain([SKYRole roleWithName:developerRoleName]);
                        expect(roles).to.contain([SKYRole roleWithName:testerRoleName]);
                        expect(roles).to.contain([SKYRole roleWithName:pmRoleName]);
                        expect(error).to.beNil();
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
