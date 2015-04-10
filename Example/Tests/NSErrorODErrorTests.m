//
//  NSErrorODErrorTests.m
//  ODKit
//
//  Created by atwork on 29/3/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>

SpecBegin(NSErrorODErrorTests)

describe(@"error", ^{
    
    it(@"error properties", ^{
        NSDictionary *userInfo = @{
                                   ODErrorCodeKey: @(200),
                                   ODErrorTypeKey: @"ERROR_TYPE",
                                   ODErrorMessageKey: @"ERROR_MESSAGE",
                                   ODErrorInfoKey: @{@"key": @"value"},
                                   };
        NSError *error = [NSError errorWithDomain:@"ODOperationErrorDomain"
                                             code:100
                                         userInfo:userInfo];
        expect([error ODErrorCode]).to.equal(200);
        expect([error ODErrorType]).to.equal(@"ERROR_TYPE");
        expect([error ODErrorMessage]).to.equal(@"ERROR_MESSAGE");
        expect([error ODErrorInfo]).to.equal(@{@"key": @"value"});
    });
});

SpecEnd
