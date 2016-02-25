//
//  SKYSetUserDefaultRoleOperationTests.m
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

SpecBegin(SKYSetUserDefaultRoleOperation)

    describe(@"Set User Default Role Operation", ^{
        NSString *apiKey = @"CORRECT_KEY";
        NSString *currentUserID = @"CORRECT_USER_ID";
        NSString *token = @"CORRECT_TOKEN";

        NSString *readerRoleName = @"Reader";
        NSString *writerRoleName = @"Writer";

        NSArray<SKYRole *> *roles =
            @[ [SKYRole roleWithName:readerRoleName], [SKYRole roleWithName:writerRoleName] ];

        __block SKYContainer *container = nil;

        beforeEach(^{
            container = [[SKYContainer alloc] init];
            [container configureWithAPIKey:apiKey];
            [container updateWithUserRecordID:currentUserID
                                  accessToken:[[SKYAccessToken alloc] initWithTokenString:token]];
        });

        it(@"should create SKYRequest correctly", ^{
            SKYSetUserDefaultRoleOperation *operation =
                [SKYSetUserDefaultRoleOperation operationWithRoles:roles];

            [operation setContainer:container];
            [operation prepareForRequest];

            SKYRequest *request = operation.request;
            expect(request.action).to.equal(@"role:default");
            expect(request.accessToken.tokenString).to.equal(token);
            expect(request.payload).to.equal(@{ @"roles" : @[ readerRoleName, writerRoleName ] });
        });

        it(@"should handle success response", ^{
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *_Nonnull request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *response =
                        @{ @"result" : @{@"roles" : @[ readerRoleName, writerRoleName ]} };

                    return [OHHTTPStubsResponse responseWithJSONObject:response
                                                            statusCode:200
                                                               headers:nil];
                }];

            SKYSetUserDefaultRoleOperation *operation =
                [SKYSetUserDefaultRoleOperation operationWithRoles:roles];

            [operation setContainer:container];

            waitUntil(^(DoneCallback done) {
                operation.setUserDefaultRoleCompletionBlock =
                    ^(NSArray<SKYRole *> *roles, NSError *error) {
                        expect(roles.count).to.equal(2);
                        expect(roles).to.contain([SKYRole roleWithName:readerRoleName]);
                        expect(roles).to.contain([SKYRole roleWithName:writerRoleName]);
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
