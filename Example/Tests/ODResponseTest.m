//
//  ODResponseTest.m
//  ODKit
//
//  Created by atwork on 15/8/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(ODResponse)

describe(@"init", ^{
    it(@"with nil", ^{
        expect(^{
            ODResponse *response = [[ODResponse alloc] initWithDictionary:nil];
            NSLog(@"%@", response);
        }).to.raise(NSInvalidArgumentException);
    });
    
    it(@"with dictionary", ^{
        NSDictionary *data = @{ @"result": @[] };
        ODResponse *response = [[ODResponse alloc] initWithDictionary:data];
        expect([response class]).to.beSubclassOf([ODResponse class]);
        expect(response.responseDictionary).to.equal(data);
    });
    
    it(@"with class method", ^{
        NSDictionary *data = @{ @"result": @[] };
        ODResponse *response = [ODResponse responseWithDictionary:data];
        expect([response class]).to.beSubclassOf([ODResponse class]);
        expect(response.responseDictionary).to.equal(data);
    });
});

describe(@"set error", ^{
    it(@"set error once", ^{
        ODResponse *response = [ODResponse responseWithDictionary:@{}];
        NSError *error = [NSError errorWithDomain:NSGenericException
                                             code:0
                                         userInfo:nil];
        [response foundResponseError:[error copy]];
        expect(response.error).to.equal(error);
    });
    
    it(@"set error twice", ^{
        ODResponse *response = [ODResponse responseWithDictionary:@{}];
        NSError *error = [NSError errorWithDomain:NSGenericException
                                             code:0
                                         userInfo:nil];
        [response foundResponseError:[error copy]];
        expect(^{
            [response foundResponseError:[error copy]];
        }).to.raise(NSGenericException);
    });
});


SpecEnd
