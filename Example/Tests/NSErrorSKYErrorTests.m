//
//  NSErrorSKYErrorTests.m
//  SkyKit
//
//  Created by atwork on 29/3/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SkyKit/SkyKit.h>

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
