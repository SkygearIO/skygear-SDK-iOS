//
//  SKYResultArrayResponseTest.m
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

SpecBegin(SKYResultArrayResponse)

    describe(@"init", ^{
        it(@"with dictionary", ^{
            NSDictionary *data = @{ @"result" : @[] };
            SKYResultArrayResponse *response =
                [[SKYResultArrayResponse alloc] initWithDictionary:data];
            expect([response class]).to.beSubclassOf([SKYResultArrayResponse class]);
            expect(response.responseDictionary).to.equal(data);
        });

        it(@"with class method", ^{
            NSDictionary *data = @{ @"result" : @[] };
            SKYResultArrayResponse *response = [SKYResultArrayResponse responseWithDictionary:data];
            expect([response class]).to.beSubclassOf([SKYResultArrayResponse class]);
            expect(response.responseDictionary).to.equal(data);
        });
    });

describe(@"correct data", ^{
    it(@"zero results", ^{
        NSDictionary *data = @{ @"result" : @[] };
        SKYResultArrayResponse *response = [SKYResultArrayResponse responseWithDictionary:data];
        expect(response.count).to.equal(@0);
        __block NSUInteger callCount = 0;
        [response enumerateResultsUsingBlock:^(NSString *resultKey, NSDictionary *result,
                                               NSError *error, NSUInteger idx, BOOL *stop) {
            callCount++;
        }];
        expect(callCount).to.equal(@0);
    });

    it(@"one result", ^{
        NSDictionary *data = @{ @"result" : @[ @{@"_id" : @"hello", @"text" : @"world"} ] };
        SKYResultArrayResponse *response = [SKYResultArrayResponse responseWithDictionary:data];
        expect(response.count).to.equal(@1);
        __block NSUInteger callCount = 0;
        [response enumerateResultsUsingBlock:^(NSString *resultKey, NSDictionary *result,
                                               NSError *error, NSUInteger idx, BOOL *stop) {

            expect(resultKey).to.equal(@"hello");
            expect(result).to.equal(data[@"result"][0]);
            expect(error).to.beNil();
            expect(idx).to.equal(@0);
            callCount++;
        }];
        expect(callCount).to.equal(@1);
    });

    it(@"two results", ^{
        NSDictionary *data = @{
            @"result" : @[
                @{@"_id" : @"hello", @"text" : @"world"},
                @{@"_id" : @"bye", @"text" : @"world"},
            ]
        };
        SKYResultArrayResponse *response = [SKYResultArrayResponse responseWithDictionary:data];
        expect(response.count).to.equal(@2);
        __block NSMutableArray *calledIDs = [NSMutableArray array];
        [response enumerateResultsUsingBlock:^(NSString *resultKey, NSDictionary *result,
                                               NSError *error, NSUInteger idx, BOOL *stop) {

            if ([resultKey isEqual:@"hello"]) {
                expect(result).to.equal(data[@"result"][0]);
                expect(error).to.beNil();
                expect(idx).to.equal(@0);
            } else if ([resultKey isEqual:@"bye"]) {
                expect(result).to.equal(data[@"result"][1]);
                expect(error).to.beNil();
                expect(idx).to.equal(@1);
            } else {
                expect(false);
            }
            [calledIDs addObject:resultKey];
        }];
        expect(calledIDs).to.haveCountOf(2);
    });

    it(@"one error", ^{
        NSDictionary *data = @{ @"result" : @[ @{@"_id" : @"hello", @"_type" : @"error"} ] };
        SKYResultArrayResponse *response = [SKYResultArrayResponse responseWithDictionary:data];
        expect(response.count).to.equal(@1);
        __block NSUInteger callCount = 0;
        [response enumerateResultsUsingBlock:^(NSString *resultKey, NSDictionary *result,
                                               NSError *error, NSUInteger idx, BOOL *stop) {

            expect(resultKey).to.equal(@"hello");
            expect([error class]).to.beSubclassOf([NSError class]);
            expect(idx).to.equal(@0);
            callCount++;
        }];
        expect(callCount).to.equal(@1);
    });
});

describe(@"incorrect data", ^{
    it(@"missing id", ^{
        NSDictionary *data = @{ @"result" : @[ @{} ] };
        SKYResultArrayResponse *response = [SKYResultArrayResponse responseWithDictionary:data];
        expect(response.count).to.equal(@1);
        __block NSUInteger callCount = 0;
        [response enumerateResultsUsingBlock:^(NSString *resultKey, NSDictionary *result,
                                               NSError *error, NSUInteger idx, BOOL *stop) {

            expect(resultKey).to.beNil();
            expect([error class]).to.beSubclassOf([NSError class]);
            expect(idx).to.equal(@0);
            callCount++;
        }];
        expect(callCount).to.equal(@1);
    });
});

describe(@"to stop", ^{
    it(@"two results", ^{
        NSDictionary *data = @{
            @"result" : @[
                @{@"_id" : @"hello", @"text" : @"world"},
                @{@"_id" : @"bye", @"text" : @"world"},
            ]
        };
        SKYResultArrayResponse *response = [SKYResultArrayResponse responseWithDictionary:data];
        __block NSUInteger callCount = 0;
        [response enumerateResultsUsingBlock:^(NSString *resultKey, NSDictionary *result,
                                               NSError *error, NSUInteger idx, BOOL *stop) {

            callCount++;
            expect(stop).toNot.beNil();
            *stop = YES;
        }];
        expect(callCount).to.equal(@1);
    });
});

SpecEnd
