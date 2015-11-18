//
//  SKYResponseTest.m
//  SkyKit
//
//  Created by atwork on 15/8/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SkyKit/SkyKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(SKYResponse)

    describe(@"init", ^{
        it(@"with nil", ^{
            expect(^{
                SKYResponse *response = [[SKYResponse alloc] initWithDictionary:nil];
                NSLog(@"%@", response);
            }).to.raise(NSInvalidArgumentException);
        });

        it(@"with dictionary", ^{
            NSDictionary *data = @{ @"result" : @[] };
            SKYResponse *response = [[SKYResponse alloc] initWithDictionary:data];
            expect([response class]).to.beSubclassOf([SKYResponse class]);
            expect(response.responseDictionary).to.equal(data);
        });

        it(@"with class method", ^{
            NSDictionary *data = @{ @"result" : @[] };
            SKYResponse *response = [SKYResponse responseWithDictionary:data];
            expect([response class]).to.beSubclassOf([SKYResponse class]);
            expect(response.responseDictionary).to.equal(data);
        });
    });

describe(@"set error", ^{
    it(@"set error once", ^{
        SKYResponse *response = [SKYResponse responseWithDictionary:@{}];
        NSError *error = [NSError errorWithDomain:NSGenericException code:0 userInfo:nil];
        [response foundResponseError:[error copy]];
        expect(response.error).to.equal(error);
    });

    it(@"set error twice", ^{
        SKYResponse *response = [SKYResponse responseWithDictionary:@{}];
        NSError *error = [NSError errorWithDomain:NSGenericException code:0 userInfo:nil];
        [response foundResponseError:[error copy]];
        expect(^{
            [response foundResponseError:[error copy]];
        }).to.raise(NSGenericException);
    });
});

SpecEnd
