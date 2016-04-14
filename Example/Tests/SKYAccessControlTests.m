//
//  SKYAccessControlTests.m
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

#import "SKYAccessControlDeserializer.h"
#import "SKYAccessControlEntry.h"
#import "SKYAccessControlSerializer.h"
#import "SKYAccessControl_Private.h"

// Currently there are no methods to access the internal state of SKYAccessControl.
// Before that comes, use serialization for assertion.
NSArray *serializedAccessControl(SKYAccessControl *accessControl)
{
    SKYAccessControlSerializer *serializer = [SKYAccessControlSerializer serializer];
    return [serializer arrayWithAccessControl:accessControl];
}

SpecBegin(SKYAccessControl)

    describe(@"Public Access Control (new)", ^{
        __block SKYAccessControl *accessControl = nil;

        beforeEach(^{
            accessControl = [SKYAccessControl publicReadableAccessControl];
        });

        it(@"contains default public read entry", ^{
            NSArray *serialized = serializedAccessControl(accessControl);
            expect(serialized).notTo.beNil();
            expect(serialized).to.equal(@[ @{ @"public" : @YES, @"level" : @"read" } ]);
        });
    });

describe(@"Access Control for user id", ^{
    __block SKYAccessControl *accessControl = nil;
    __block NSString *userID = nil;

    beforeEach(^{
        userID = @"userid";

        accessControl = [SKYAccessControl
            accessControlWithEntries:@[ [SKYAccessControlEntry writeEntryForUserID:userID] ]];
    });

    it(@"is serialized correctly", ^{
        expect(serializedAccessControl(accessControl)).to.equal(@[
            @{ @"relation" : @"$direct",
               @"level" : @"write",
               @"user_id" : @"userid" },
        ]);
    });

    it(@"can be set to read only", ^{
        [accessControl setReadOnlyForUserID:userID];
        expect(accessControl.entries).to.haveCountOf(1);
        expect(serializedAccessControl(accessControl)).to.equal(@[
            @{ @"relation" : @"$direct",
               @"level" : @"read",
               @"user_id" : @"userid" }
        ]);
    });

    it(@"can be set to no access", ^{
        [accessControl setNoAccessForUserID:userID];
        expect(accessControl.entries).to.haveCountOf(0);
        expect(serializedAccessControl(accessControl)).to.equal(@[]);
    });

    it(@"does not add duplicated entry", ^{
        [accessControl setReadWriteAccessForUserID:@"userid"];
        expect(accessControl.entries).to.haveCountOf(1);
        expect(serializedAccessControl(accessControl)).to.equal(@[
            @{ @"relation" : @"$direct",
               @"level" : @"write",
               @"user_id" : @"userid" },
        ]);
    });
});

describe(@"Access Control for relation", ^{
    __block SKYAccessControl *accessControl = nil;
    __block SKYRelation *friendRelation = [SKYRelation friendRelation];

    beforeEach(^{
        friendRelation = [SKYRelation friendRelation];

        accessControl =
            [SKYAccessControl accessControlWithEntries:@[ [SKYAccessControlEntry
                                                           writeEntryForRelation:friendRelation] ]];
    });

    it(@"is serialized correctly", ^{
        expect(serializedAccessControl(accessControl)).to.equal(@[
            @{ @"relation" : @"friend",
               @"level" : @"write" },
        ]);
    });

    it(@"can be set to read only", ^{
        [accessControl setReadOnlyForRelation:friendRelation];
        expect(accessControl.entries).to.haveCountOf(1);
        expect(serializedAccessControl(accessControl)).to.equal(@[
            @{ @"relation" : @"friend",
               @"level" : @"read" }
        ]);
    });

    it(@"can be set to no access", ^{
        [accessControl setNoAccessForRelation:friendRelation];
        expect(accessControl.entries).to.haveCountOf(0);
        expect(serializedAccessControl(accessControl)).to.equal(@[]);
    });

    it(@"does not add duplicated entry", ^{
        [accessControl setReadWriteAccessForRelation:friendRelation];
        expect(accessControl.entries).to.haveCountOf(1);
        expect(serializedAccessControl(accessControl)).to.equal(@[
            @{ @"relation" : @"friend",
               @"level" : @"write" },
        ]);
    });
});

describe(@"Access Control for role", ^{
    __block SKYAccessControl *accessControl = nil;
    __block SKYRole *adminRole = nil;

    beforeEach(^{
        adminRole = [SKYRole roleWithName:@"admin"];

        accessControl = [SKYAccessControl
            accessControlWithEntries:@[ [SKYAccessControlEntry writeEntryForRole:adminRole] ]];
    });

    it(@"is serialized correctly", ^{
        expect(serializedAccessControl(accessControl)).to.equal(@[
            @{ @"role" : @"admin",
               @"level" : @"write" },
        ]);
    });

    it(@"can be set to read only", ^{
        [accessControl setReadOnlyForRole:adminRole];
        expect(accessControl.entries).to.haveCountOf(1);
        expect(serializedAccessControl(accessControl)).to.equal(@[
            @{ @"role" : @"admin",
               @"level" : @"read" }
        ]);
    });

    it(@"can be set to no access", ^{
        [accessControl setNoAccessForRole:adminRole];
        expect(accessControl.entries).to.haveCountOf(0);
        expect(serializedAccessControl(accessControl)).to.equal(@[]);
    });

    it(@"does not add duplicated entry", ^{
        [accessControl setReadWriteAccessForRole:adminRole];
        expect(accessControl.entries).to.haveCountOf(1);
        expect(serializedAccessControl(accessControl)).to.equal(@[
            @{ @"role" : @"admin",
               @"level" : @"write" },
        ]);
    });
});

describe(@"Access Control for public", ^{
    __block SKYAccessControl *accessControl = nil;

    beforeEach(^{
        accessControl = [SKYAccessControl
            accessControlWithEntries:@[ [SKYAccessControlEntry writeEntryForPublic] ]];
    });

    it(@"is serialized correctly", ^{
        expect(serializedAccessControl(accessControl)).to.equal(@[
            @{ @"public" : @YES,
               @"level" : @"write" },
        ]);
    });

    it(@"can be set to read only", ^{
        [accessControl setReadOnlyForPublic];
        expect(accessControl.entries).to.haveCountOf(1);
        expect(serializedAccessControl(accessControl)).to.equal(@[
            @{ @"public" : @YES,
               @"level" : @"read" }
        ]);
    });

    it(@"can be set to no access", ^{
        [accessControl setNoAccessForPublic];
        expect(accessControl.entries).to.haveCountOf(0);
        expect(serializedAccessControl(accessControl)).to.equal(@[]);
    });

    it(@"does not add duplicated entry", ^{
        [accessControl setReadWriteAccessForPublic];
        expect(accessControl.entries).to.haveCountOf(1);
        expect(serializedAccessControl(accessControl)).to.equal(@[
            @{ @"public" : @YES,
               @"level" : @"write" },
        ]);
    });
});

describe(@"Default Access Control", ^{
    beforeEach(^{
        [SKYAccessControl setDefaultAccessControl:nil];
    });

    it(@"should be public readable ACL by default", ^{
        SKYAccessControl *acl = [SKYAccessControl defaultAccessControl];

        expect(acl.entries).to.haveACountOf(1);

        SKYAccessControlEntry *firstEntry = acl.entries[0];
        expect(firstEntry.accessLevel).to.equal(SKYAccessControlEntryLevelRead);
        expect(firstEntry.entryType).to.equal(SKYAccessControlEntryTypePublic);
    });

    it(@"should be able to set default ACL", ^{
        SKYRole *developerRole = [SKYRole roleWithName:@"Developer"];
        SKYUser *user0 = [SKYUser userWithUserID:@"20A4F099-A9B1-490F-857D-2E9A5B128B16"];
        SKYRelation *friendRelation = [SKYRelation friendRelation];

        SKYAccessControl *defaultACL = [SKYAccessControl defaultAccessControl];
        // Should be public readable
        expect([defaultACL hasReadAccessForRole:developerRole]).to.equal(YES);
        expect([defaultACL hasReadAccessForUser:user0]).to.equal(YES);
        expect([defaultACL hasReadAccessForRelation:friendRelation]).to.equal(YES);

        // Should be public NOT writable
        expect([defaultACL hasWriteAccessForRole:developerRole]).to.equal(NO);
        expect([defaultACL hasWriteAccessForUser:user0]).to.equal(NO);
        expect([defaultACL hasWriteAccessForRelation:friendRelation]).to.equal(NO);

        SKYAccessControl *acl = [SKYAccessControl accessControlWithEntries:@[
            [SKYAccessControlEntry readEntryForRole:developerRole],
            [SKYAccessControlEntry writeEntryForRole:developerRole],
            [SKYAccessControlEntry readEntryForUser:user0],
            [SKYAccessControlEntry readEntryForRelation:friendRelation]
        ]];
        [SKYAccessControl setDefaultAccessControl:acl];

        defaultACL = [SKYAccessControl defaultAccessControl];
        expect([defaultACL hasReadAccessForRole:developerRole]).to.equal(YES);
        expect([defaultACL hasWriteAccessForRole:developerRole]).to.equal(YES);
        expect([defaultACL hasReadAccessForUser:user0]).to.equal(YES);
        expect([defaultACL hasWriteAccessForUser:user0]).to.equal(NO);
        expect([defaultACL hasReadAccessForRelation:friendRelation]).to.equal(YES);
        expect([defaultACL hasWriteAccessForRelation:friendRelation]).to.equal(NO);
    });

    afterEach(^{
        [SKYAccessControl setDefaultAccessControl:nil];
    });
});

describe(@"Access Control Entry", ^{
    SKYRole *humanRole = [SKYRole roleWithName:@"Human"];
    SKYRole *godRole = [SKYRole roleWithName:@"God"];
    SKYRelation *friendRelation = [SKYRelation friendRelation];
    SKYRelation *followedRelation = [SKYRelation followedRelation];

    SKYAccessControlEntry *readRelationEntry =
        [SKYAccessControlEntry readEntryForRelation:friendRelation];
    SKYAccessControlEntry *writeRelationEntry =
        [SKYAccessControlEntry writeEntryForRelation:followedRelation];

    SKYAccessControlEntry *readUserIDEntry = [SKYAccessControlEntry readEntryForUserID:@"userid0"];
    SKYAccessControlEntry *writeUserIDEntry =
        [SKYAccessControlEntry writeEntryForUserID:@"userid1"];

    SKYAccessControlEntry *readRoleEntry = [SKYAccessControlEntry readEntryForRole:humanRole];
    SKYAccessControlEntry *writeRoleEntry = [SKYAccessControlEntry writeEntryForRole:godRole];

    it(@"serializes correctly", ^{
        SKYAccessControl *accessControl = [SKYAccessControl accessControlWithEntries:@[
            readRelationEntry, writeRelationEntry, readUserIDEntry, writeUserIDEntry, readRoleEntry,
            writeRoleEntry
        ]];
        expect(serializedAccessControl(accessControl)).to.equal(@[
            @{ @"relation" : @"friend",
               @"level" : @"read" },
            @{ @"relation" : @"follow",
               @"level" : @"write" },
            @{ @"relation" : @"$direct",
               @"level" : @"read",
               @"user_id" : @"userid0" },
            @{ @"relation" : @"$direct",
               @"level" : @"write",
               @"user_id" : @"userid1" },
            @{ @"level" : @"read",
               @"role" : @"Human" },
            @{ @"level" : @"write",
               @"role" : @"God" },
        ]);
    });

    it(@"checks access correctly", ^{
        SKYAccessControl *accessControl = [SKYAccessControl accessControlWithEntries:@[
            readRelationEntry, writeRelationEntry, readUserIDEntry, writeUserIDEntry, readRoleEntry,
            writeRoleEntry
        ]];

        expect([accessControl hasReadAccessForRelation:friendRelation]).to.equal(YES);
        expect([accessControl hasWriteAccessForRelation:followedRelation]).to.equal(YES);
        expect([accessControl hasReadAccessForUserID:@"userid0"]).to.equal(YES);
        expect([accessControl hasWriteAccessForUserID:@"userid1"]).to.equal(YES);
        expect([accessControl hasReadAccessForRole:humanRole]).to.equal(YES);
        expect([accessControl hasWriteAccessForRole:godRole]).to.equal(YES);

        [accessControl setNoAccessForRelation:friendRelation];
        [accessControl setNoAccessForUserID:@"userid0"];
        [accessControl setNoAccessForRole:humanRole];

        expect([accessControl hasReadAccessForRelation:friendRelation]).to.equal(NO);
        expect([accessControl hasWriteAccessForRelation:followedRelation]).to.equal(YES);
        expect([accessControl hasReadAccessForUserID:@"userid0"]).to.equal(NO);
        expect([accessControl hasWriteAccessForUserID:@"userid1"]).to.equal(YES);
        expect([accessControl hasReadAccessForRole:humanRole]).to.equal(NO);
        expect([accessControl hasWriteAccessForRole:godRole]).to.equal(YES);

        [accessControl setReadOnlyForRelation:followedRelation];
        [accessControl setReadOnlyForUserID:@"userid1"];
        [accessControl setReadOnlyForRole:godRole];

        expect([accessControl hasReadAccessForRelation:friendRelation]).to.equal(NO);
        expect([accessControl hasWriteAccessForRelation:followedRelation]).to.equal(NO);
        expect([accessControl hasReadAccessForUserID:@"userid0"]).to.equal(NO);
        expect([accessControl hasWriteAccessForUserID:@"userid1"]).to.equal(NO);
        expect([accessControl hasReadAccessForRole:humanRole]).to.equal(NO);
        expect([accessControl hasWriteAccessForRole:godRole]).to.equal(NO);
    });
});

describe(@"SKYAccessControlDeserializer", ^{

    __block SKYAccessControlDeserializer *deserializer = nil;

    beforeEach(^{
        deserializer = [SKYAccessControlDeserializer deserializer];
    });

    it(@"deserializes public access correctly", ^{
        SKYAccessControl *accessControl = [deserializer accessControlWithArray:nil];
        expect(accessControl).to.beNil();
    });

    it(@"empty array", ^{
        SKYAccessControl *accessControl = [deserializer accessControlWithArray:@[]];
        expect(accessControl.entries).to.haveCountOf(0);
        expect(serializedAccessControl(accessControl)).to.equal(@[]);
    });

    it(@"access control entries", ^{
        NSArray *undeserialized = @[
            @{ @"relation" : @"friend",
               @"level" : @"read" },
            @{ @"relation" : @"follow",
               @"level" : @"write" },
            @{ @"relation" : @"$direct",
               @"level" : @"read",
               @"user_id" : @"userid0" },
            @{ @"relation" : @"$direct",
               @"level" : @"write",
               @"user_id" : @"userid1" },
            @{ @"level" : @"read",
               @"role" : @"Human" },
            @{ @"level" : @"write",
               @"role" : @"God" },
        ];
        SKYAccessControl *accessControl = [deserializer accessControlWithArray:undeserialized];
        expect(accessControl.entries).to.haveCountOf(6);
        expect(serializedAccessControl(accessControl)).to.equal(undeserialized);
    });

});

SpecEnd
