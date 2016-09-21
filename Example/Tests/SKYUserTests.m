//
//  SKYUser.m
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

#import "SKYUser_Private.h"

SpecBegin(SKYUser)

    describe(@"SKYUser", ^{
        it(@"should be initialized correctly", ^{
            SKYUser *user1 = [[SKYUser alloc] initWithUserID:@"user_id1"];
            expect(user1.userID).to.equal(@"user_id1");
            expect(user1.lastLoginAt).to.beNil();

            SKYUser *user2 = [SKYUser userWithUserID:@"user_id2"];
            expect(user2.userID).to.equal(@"user_id2");
        });

        it(@"should manipulate roles correctly", ^{
            SKYRole *developerRole = [SKYRole roleWithName:@"Developer"];
            SKYRole *testerRole = [SKYRole roleWithName:@"Tester"];
            SKYRole *pmRole = [SKYRole roleWithName:@"Project Manager"];

            SKYUser *user = [SKYUser userWithUserID:@"user_id"];
            user.roles = @[ developerRole, testerRole ];

            expect(user.roles).to.haveACountOf(2);
            expect([user hasRole:developerRole]).to.equal(YES);
            expect([user hasRole:testerRole]).to.equal(YES);
            expect([user hasRole:pmRole]).to.equal(NO);

            [user addRole:pmRole];
            expect(user.roles).to.haveACountOf(3);
            expect([user hasRole:pmRole]).to.equal(YES);

            [user removeRole:testerRole];
            expect(user.roles).to.haveACountOf(2);
            expect([user hasRole:testerRole]).to.equal(NO);
        });
    });

SpecEnd
