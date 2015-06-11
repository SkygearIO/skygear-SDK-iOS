//
//  ODAccessControlTests.m
//  ODKit
//
//  Created by Kenji Pa on 10/6/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <ODKit/ODKit.h>

#import "ODAccessControl_Private.h"
#import "ODAccessControlEntry.h"
#import "ODAccessControlSerializer.h"
#import "ODUserRecordID_Private.h"

// Currently there are no methods to access the internal state of ODAccessControl.
// Before that comes, use serialization for assertion.
NSArray *serializedAccessControl(ODAccessControl *accessControl) {
    ODAccessControlSerializer *serializer = [ODAccessControlSerializer serializer];
    return [serializer arrayWithAccessControl:accessControl];
}

SpecBegin(ODAccessControl)

describe(@"Public Access Control", ^{
    __block ODAccessControl *accessControl = nil;

    beforeEach(^{
        accessControl = [ODAccessControl publicReadWriteAccessControl];
    });

    it(@"is public", ^{
        expect(accessControl.public).to.equal(YES);
        expect(serializedAccessControl(accessControl)).to.equal(nil);
    });

    it(@"is not public after mutated", ^{
        [accessControl addReadAccessForRelation:[ODRelation relationFollow]];
        expect(accessControl.public).to.equal(NO);
        expect(serializedAccessControl(accessControl)).to.equal(@[
                                                                  @{@"relation": @"follow", @"level": @"read"},
                                                                  ]);
    });
});

describe(@"Access Control", ^{
    __block ODAccessControl *accessControl = nil;
    __block ODUserRecordID *userID = nil;

    beforeEach(^{
        userID = [ODUserRecordID recordIDWithUsername:@"userid"];

        ODAccessControlEntry* entry = [ODAccessControlEntry writeEntryForUserID:userID];
        accessControl = [ODAccessControl accessControlWithEntries:@[entry]];
    });

    it(@"is not public", ^{
        expect(accessControl.public).to.equal(NO);
        expect(serializedAccessControl(accessControl)).to.equal(@[
                                                                  @{@"relation": @"$direct", @"level": @"write", @"user_id": @"userid"},
                                                                  ]);
    });

    it(@"is not public after removing all entries", ^{
        [accessControl removeWriteAccessForUserID:userID];
        expect(accessControl.public).to.equal(NO);
        expect(serializedAccessControl(accessControl)).to.equal(@[]);
    });

    it(@"is public after setting public read write access", ^{
        [accessControl setPublicReadWriteAccess];
        expect(accessControl.public).to.equal(YES);
        expect(serializedAccessControl(accessControl)).to.equal(nil);
    });

    it(@"does not add same entry twice", ^{
        [accessControl addWriteAccessForUserID:[ODUserRecordID recordIDWithUsername:@"userid"]];
        expect(serializedAccessControl(accessControl)).to.equal(@[
                                                                  @{@"relation": @"$direct", @"level": @"write", @"user_id": @"userid"},
                                                                  ]);
    });
});

describe(@"Access Control Entry", ^{
    it(@"serializes correctly", ^{
        ODAccessControlEntry *readRelationEntry = [ODAccessControlEntry readEntryForRelation:[ODRelation relationFriend]];
        ODAccessControlEntry *writeRelationEntry = [ODAccessControlEntry writeEntryForRelation:[ODRelation relationFollow]];
        ODAccessControlEntry *readUserIDEntry = [ODAccessControlEntry readEntryForUserID:[ODUserRecordID recordIDWithUsername:@"userid0"]];
        ODAccessControlEntry *writeUserIDEntry = [ODAccessControlEntry writeEntryForUserID:[ODUserRecordID recordIDWithUsername:@"userid1"]];

        ODAccessControl *accessControl = [ODAccessControl accessControlWithEntries:@[
                                                                                     readRelationEntry,
                                                                                     writeRelationEntry,
                                                                                     readUserIDEntry,
                                                                                     writeUserIDEntry,
                                                                                     ]];
        expect(serializedAccessControl(accessControl)).to.equal(@[
                                                                  @{@"relation": @"friend", @"level": @"read"},
                                                                  @{@"relation": @"follow", @"level": @"write"},
                                                                  @{@"relation": @"$direct", @"level": @"read", @"user_id": @"userid0"},
                                                                  @{@"relation": @"$direct", @"level": @"write", @"user_id": @"userid1"},
                                                                  ]);
    });
});

SpecEnd

