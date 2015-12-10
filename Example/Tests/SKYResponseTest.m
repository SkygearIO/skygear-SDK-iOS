//
//  SKYResponseTest.m
//  SkyKit
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
