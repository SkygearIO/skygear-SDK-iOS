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

SpecBegin(NSErrorSKYErrorTests)

    describe(@"error", ^{

        it(@"error properties", ^{
            NSDictionary *userInfo = @{
                SKYErrorCodeKey : @(200),
                SKYErrorTypeKey : @"ERROR_TYPE",
                SKYErrorMessageKey : @"ERROR_MESSAGE",
                SKYErrorInfoKey : @{@"key" : @"value"},
            };
            NSError *error =
                [NSError errorWithDomain:@"SKYOperationErrorDomain" code:100 userInfo:userInfo];
            expect([error SKYErrorCode]).to.equal(200);
            expect([error SKYErrorType]).to.equal(@"ERROR_TYPE");
            expect([error SKYErrorMessage]).to.equal(@"ERROR_MESSAGE");
            expect([error SKYErrorInfo]).to.equal(@{ @"key" : @"value" });
        });
    });

SpecEnd
