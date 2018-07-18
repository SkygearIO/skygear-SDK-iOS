//
//  NSErrorSKYErrorTests.m
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

SpecBegin(SKYErrorCreatorTests)

    describe(@"error", ^{
        __block SKYErrorCreator *creator = nil;

        beforeEach(^{
            creator = [[SKYErrorCreator alloc] init];
        });

        it(@"create error", ^{
            NSError *error = [creator errorWithResponseDictionary:@{
                @"code" : @(SKYErrorUnknownError),
                @"name" : @"UnknownError",
                @"message" : @"Unknown error has occurred.",
                @"info" : @{@"key" : @"value"},
            }];
            expect(error.domain).to.equal(SKYOperationErrorDomain);
            expect(error.code).to.equal(SKYErrorUnknownError);
            expect(error.localizedDescription)
                .to.equal(SKYErrorLocalizedDescriptionWithCodeAndInfo(SKYErrorUnknownError, error.userInfo));
            expect(error.userInfo[SKYErrorMessageKey]).to.equal(@"Unknown error has occurred.");
            expect(error.userInfo[SKYErrorNameKey]).to.equal(@"UnknownError");
            expect(error.userInfo[@"key"]).to.equal(@"value");
        });
    });

SpecEnd
