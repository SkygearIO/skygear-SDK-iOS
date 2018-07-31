//
//  SKYAuthContainerForgotPasswordTests.m
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
#import <SKYKit/SKYAuthContainer_Private.h>
#import <SKYKit/SKYKit.h>

SpecBegin(SKYAuthContainerForgotPassword)

    describe(@"Verify Code", ^{
        it(@"should create and add operation", ^{
            id container = OCMClassMock([SKYContainer class]);
            SKYAuthContainer *auth =
                [[SKYAuthContainer alloc] initWithContainer:(SKYContainer *)container];

            NSString *verificationCode = @"123456";

            OCMExpect([container
                addOperation:[OCMArg checkWithBlock:^BOOL(SKYLambdaOperation *operation) {
                    if ([operation isKindOfClass:[SKYLambdaOperation class]]) {
                        expect(operation.action).to.equal(@"user:verify_code");
                        expect(operation.dictionaryArguments).to.equal(@{
                            @"code" : verificationCode
                        });
                        operation.lambdaCompletionBlock(@{}, nil);
                        return YES;
                    }
                    return NO;
                }]]);
            OCMExpect([container
                addOperation:[OCMArg checkWithBlock:^BOOL(SKYGetCurrentUserOperation *operation) {
                    if ([operation isKindOfClass:[SKYGetCurrentUserOperation class]]) {
                        operation.getCurrentUserCompletionBlock(nil, nil, nil);
                        return YES;
                    }
                    return NO;
                }]]);

            waitUntil(^(DoneCallback done) {
                [auth verifyUserWithCode:verificationCode
                              completion:^(SKYRecord *_Nullable user, NSError *_Nullable error) {
                                  expect(error).to.beNil();
                                  done();
                              }];
            });

            OCMVerifyAll(container);
        });
    });

describe(@"Verify Request", ^{
    it(@"should create and add operation", ^{
        id container = OCMClassMock([SKYContainer class]);
        SKYAuthContainer *auth =
            [[SKYAuthContainer alloc] initWithContainer:(SKYContainer *)container];

        NSString *recordKey = @"phone";

        OCMExpect([container
            addOperation:[OCMArg checkWithBlock:^BOOL(SKYLambdaOperation *operation) {
                expect(operation.action).to.equal(@"user:verify_request");
                expect(operation.dictionaryArguments).to.equal(@{@"record_key" : recordKey});
                operation.lambdaCompletionBlock(@{}, nil);
                return YES;
            }]]);

        waitUntil(^(DoneCallback done) {
            [auth requestVerification:recordKey
                           completion:^(NSError *error) {
                               expect(error).to.beNil();
                               done();
                           }];
        });

        OCMVerifyAll(container);
    });
});

SpecEnd
