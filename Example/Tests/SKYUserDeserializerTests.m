//
//  SKYUserDeserializerTests.m
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

#import <SKYKit/SKYKit.h>

SpecBegin(SKYUserDeserializerTests)

    describe(@"deserialize", ^{
        __block SKYUserDeserializer *deserializer = nil;

        beforeEach(^{
            deserializer = [SKYUserDeserializer deserializer];
        });

        it(@"init", ^{
            SKYUserDeserializer *deserializer = [SKYUserDeserializer deserializer];
            expect([deserializer class]).to.beSubclassOf([SKYUserDeserializer class]);
        });

        it(@"return nil on nil", ^{
            SKYUser *user = [deserializer userWithDictionary:nil];
            expect(user).to.beNil();
        });

        it(@"return nil on empty dict", ^{
            SKYUser *user = [deserializer userWithDictionary:@{}];
            expect(user).to.beNil();
        });

        it(@"deserialize user", ^{
            NSDictionary *data = @{
                @"_id" : @"userid",
                @"email" : @"john.doe@gmail.com",
                @"authData" : @{
                    @"authMethod" : @{@"key" : @"value"},
                },
            };

            SKYUser *user = [deserializer userWithDictionary:data];
            expect(user.userID).to.equal(@"userid");
            expect(user.email).to.equal(@"john.doe@gmail.com");
            expect(user.authData).to.equal(@{ @"authMethod" : @{@"key" : @"value"} });
        });

        it(@"deserialize user with id only", ^{
            NSDictionary *data = @{ @"_id" : @"userid" };
            SKYUser *user = [deserializer userWithDictionary:data];
            expect(user.userID).to.equal(@"userid");
        });

        it(@"return nil if id is missing", ^{
            NSDictionary *data = @{
                @"email" : @"john.doe@gmail.com",
                @"authData" : @{
                    @"authMethod" : @{@"key" : @"value"},
                },
            };
            SKYUser *user = [deserializer userWithDictionary:data];
            expect(user).to.beNil();
        });

        it(@"return empty roles if missing", ^{
            NSDictionary *data = @{ @"_id" : @"userid" };
            SKYUser *user = [deserializer userWithDictionary:data];
            expect(user.roles).notTo.beNil();
            expect(user.roles).to.haveACountOf(0);
        });

        it(@"deserialize roles correctly", ^{
            NSDictionary *data = @{ @"_id" : @"userid", @"roles" : @[ @"Tester", @"Developer" ] };

            SKYUser *user = [deserializer userWithDictionary:data];
            expect(user.roles).notTo.beNil();
            expect(user.roles).to.haveACountOf(2);
            expect([user hasRole:[SKYRole roleWithName:@"Tester"]]).to.equal(YES);
            expect([user hasRole:[SKYRole roleWithName:@"Developer"]]).to.equal(YES);
        });

    });

SpecEnd
