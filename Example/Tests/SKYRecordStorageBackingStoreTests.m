//
//  SKYRecordStorageBackingStoreTests.m
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

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <SKYKit/SKYKit.h>

#import "SKYRecordChange_Private.h"
#import "SKYRecordStorageFileBackedMemoryStore.h"
#import "SKYRecordStorageMemoryStore.h"
#import "SKYRecordStorageSqliteStore.h"
#import "SKYRecordSynchronizer.h"

@interface SKYRecordStorageBackingStoreSpecTempFileProvider : NSObject

+ (NSString *)temporaryFileWithSuffix:(NSString *)suffix;

@end

@implementation SKYRecordStorageBackingStoreSpecTempFileProvider

+ (NSString *)temporaryFileWithSuffix:(NSString *)suffix
{
    NSString *pathComponent = [NSString stringWithFormat:@"tmpXXXXXX%@", suffix];
    NSString *tempFileTemplate =
        [NSTemporaryDirectory() stringByAppendingPathComponent:pathComponent];

    const char *tempFileTemplateCString = [tempFileTemplate fileSystemRepresentation];

    char *tempFileNameCString = (char *)malloc(strlen(tempFileTemplateCString) + 1);
    strcpy(tempFileNameCString, tempFileTemplateCString);
    int fileDescriptor = mkstemps(tempFileNameCString, (int)[suffix length]);

    // no need to keep it open
    close(fileDescriptor);

    if (fileDescriptor == -1) {
        NSLog(@"Error while creating tmp file");
        return nil;
    }

    NSString *tempFileName = [[NSFileManager defaultManager]
        stringWithFileSystemRepresentation:tempFileNameCString
                                    length:strlen(tempFileNameCString)];

    free(tempFileNameCString);

    return tempFileName;
}

@end

SharedExamplesBegin(SKYRecordStorageBackingStore)

    sharedExamples(@"SKYRecordStorageBackingStore-Changes", ^(NSDictionary *data) {
        __block id<SKYRecordStorageBackingStore> backingStore;

        beforeEach(^{
            if (data[@"backingStoreFactory"]) {
                id<SKYRecordStorageBackingStore> (^factory)() = data[@"backingStoreFactory"];
                backingStore = factory();
            } else {
                backingStore = data[@"backingStore"];
            }
        });

        it(@"appending change and state changes", ^{
            SKYRecordID *recordID = [[SKYRecordID alloc] initWithCanonicalString:@"book/book1"];
            SKYRecordChange *change;
            NSDictionary *attrs = @{ @"title" : @[ [NSNull null], @"Hello World" ] };
            change = [[SKYRecordChange alloc] initWithRecordID:recordID
                                                        action:SKYRecordChangeSave
                                                 resolveMethod:SKYRecordResolveByReplacing
                                              attributesToSave:attrs];

            // Append pending change
            [backingStore appendChange:change];
            [backingStore synchronize];

            expect([backingStore failedChanges]).to.haveCountOf(0);
            expect([backingStore pendingChangesCount]).to.equal(1);
            change = [[backingStore pendingChanges] firstObject];
            expect(change.recordID).to.equal(recordID);
            expect(change.finished).to.beFalsy();

            // Get change with Record ID
            SKYRecordChange *returnedChange = [backingStore changeWithRecordID:recordID];
            expect(returnedChange.finished).to.beFalsy();

            // Set change to failed
            NSError *error = [NSError errorWithDomain:@"Error" code:0 userInfo:nil];
            [backingStore setFinishedWithError:error change:change];
            [backingStore synchronize];

            expect([backingStore failedChanges]).to.haveCountOf(1);
            expect([backingStore pendingChangesCount]).to.equal(0);
            change = [[backingStore failedChanges] firstObject];
            expect(change.recordID).to.equal(recordID);
            expect(change.finished).to.beTruthy();
            expect(change.error.domain).to.equal(@"Error");

            // Remove the change
            [backingStore removeChange:change];
            [backingStore synchronize];
            expect([backingStore failedChanges]).to.haveCountOf(0);
            expect([backingStore pendingChangesCount]).to.equal(0);
        });

        it(@"two changes", ^{
            SKYRecordID *recordID1 = [[SKYRecordID alloc] initWithCanonicalString:@"book/book1"];
            SKYRecordID *recordID2 = [[SKYRecordID alloc] initWithCanonicalString:@"book/book1"];
            SKYRecordChange *change1;
            SKYRecordChange *change2;
            NSDictionary *attrs = @{ @"title" : @[ [NSNull null], @"Hello World" ] };
            change1 = [[SKYRecordChange alloc] initWithRecordID:recordID1
                                                         action:SKYRecordChangeSave
                                                  resolveMethod:SKYRecordResolveByReplacing
                                               attributesToSave:attrs];
            change2 = [[SKYRecordChange alloc] initWithRecordID:recordID2
                                                         action:SKYRecordChangeDelete
                                                  resolveMethod:SKYRecordResolveByReplacing
                                               attributesToSave:nil];

            // Append pending change
            [backingStore appendChange:change1];
            [backingStore appendChange:change2];
            [backingStore synchronize];

            expect([backingStore failedChanges]).to.haveCountOf(0);
            expect([backingStore pendingChanges]).to.haveCountOf(2);

            NSError *error = [NSError errorWithDomain:@"Error" code:0 userInfo:nil];

            [backingStore setFinishedWithError:error change:change1];
            [backingStore setFinishedWithError:error change:change2];
            [backingStore synchronize];

            expect([backingStore failedChanges]).to.haveCountOf(2);
            expect([backingStore pendingChanges]).to.haveCountOf(0);
        });

        it(@"Appended changes of various data types", ^{
            NSDate *dateNow = [NSDate date];
            CLLocation *loc = [[CLLocation alloc] initWithLatitude:1 longitude:2];

            SKYRecordID *recordID = [[SKYRecordID alloc] initWithCanonicalString:@"book/book1"];
            SKYRecordChange *change;
            NSDictionary *attrs = @{
                @"text" : @[ [NSNull null], @"Hello World" ],
                @"sequence" : @[ [NSNull null], [[SKYSequence alloc] init] ],
                @"number" : @[ [NSNull null], @(1) ],
                @"date" : @[ [NSNull null], dateNow ],
                @"loc" : @[ [NSNull null], loc ],
            };
            change = [[SKYRecordChange alloc] initWithRecordID:recordID
                                                        action:SKYRecordChangeSave
                                                 resolveMethod:SKYRecordResolveByReplacing
                                              attributesToSave:attrs];

            // Append pending change
            [backingStore appendChange:change];
            [backingStore synchronize];
        });
    });

sharedExamples(@"SKYRecordStorageBackingStore-Records", ^(NSDictionary *data) {
    __block id<SKYRecordStorageBackingStore> backingStore;
    __block SKYRecordID *recordID;
    __block SKYRecord *record;
    __block SKYRecord *localRecord;

    beforeEach(^{
        if (data[@"backingStoreFactory"]) {
            id<SKYRecordStorageBackingStore> (^factory)() = data[@"backingStoreFactory"];
            backingStore = factory();
        } else {
            backingStore = data[@"backingStore"];
        }
        recordID = [[SKYRecordID alloc] initWithRecordType:@"book"];
        record = [[SKYRecord alloc] initWithRecordID:recordID data:nil];
        record[@"title"] = @"Hello World";
        record.transient[@"temporary"] = @YES;
        record.creationDate = [NSDate date];
        record.creatorUserRecordID = @"creator_user_id";
        record.modificationDate = [NSDate date];
        record.lastModifiedUserRecordID = @"modifier_user_id";
        record.ownerUserRecordID = @"owner_user_id";

        localRecord = [[SKYRecord alloc] initWithRecordID:recordID data:nil];
        localRecord[@"title"] = @"Hello World 2";
        localRecord.transient[@"temporary"] = @NO;
    });

    it(@"save, fetch, delete", ^{
        // Save record
        [backingStore saveRecord:record];
        [backingStore synchronize];

        NSArray *recordIDs = [backingStore recordIDsWithRecordType:@"book"];
        expect(recordIDs).to.haveCountOf(1);

        // Fetch record
        SKYRecord *fetchedRecord = [backingStore fetchRecordWithRecordID:record.recordID];
        expect(fetchedRecord[@"title"]).to.equal(record[@"title"]);
        expect(fetchedRecord.transient[@"temporary"]).to.equal(@YES);
        expect(fetchedRecord.creationDate).toNot.beNil();
        expect(fetchedRecord.lastModifiedUserRecordID).to.equal(@"modifier_user_id");

        // Modify record
        record[@"title"] = @"Bye World";
        [backingStore saveRecord:record];
        [backingStore synchronize];
        fetchedRecord = [backingStore fetchRecordWithRecordID:record.recordID];
        expect(fetchedRecord[@"title"]).to.equal(record[@"title"]);
        expect(fetchedRecord.transient[@"temporary"]).to.equal(record.transient[@"temporary"]);

        // Delete record
        [backingStore deleteRecord:record];
        [backingStore synchronize];

        recordIDs = [backingStore recordIDsWithRecordType:@"book"];
        expect(recordIDs).to.haveCountOf(0);
        expect([backingStore fetchRecordWithRecordID:record.recordID]).to.beNil();
    });

    it(@"save, fetch, revert locally", ^{
        [backingStore saveRecord:record];
        [backingStore synchronize];

        // Save record
        [backingStore saveRecordLocally:localRecord];
        [backingStore synchronize];

        NSArray *recordIDs = [backingStore recordIDsWithRecordType:@"book"];
        expect(recordIDs).to.haveCountOf(1);

        // Fetch record
        SKYRecord *fetchedRecord = [backingStore fetchRecordWithRecordID:recordID];
        expect(fetchedRecord[@"title"]).to.equal(localRecord[@"title"]);
        expect(fetchedRecord.transient[@"temporary"]).to.equal(localRecord.transient[@"temporary"]);

        // Modify local record
        localRecord[@"title"] = @"Bye World 2";
        [backingStore saveRecordLocally:localRecord];
        [backingStore synchronize];
        fetchedRecord = [backingStore fetchRecordWithRecordID:recordID];
        expect(fetchedRecord[@"title"]).to.equal(localRecord[@"title"]);
        expect(fetchedRecord.transient[@"temporary"]).to.equal(localRecord.transient[@"temporary"]);

        // Revert local record
        [backingStore revertRecordLocallyWithRecordID:recordID];
        [backingStore synchronize];

        recordIDs = [backingStore recordIDsWithRecordType:@"book"];
        expect(recordIDs).to.haveCountOf(1);
        fetchedRecord = [backingStore fetchRecordWithRecordID:recordID];
        expect(fetchedRecord[@"title"]).to.equal(record[@"title"]);
        expect(fetchedRecord.transient[@"temporary"]).to.equal(record.transient[@"temporary"]);
    });

    it(@"delete locally then revert", ^{
        [backingStore saveRecord:record];
        [backingStore synchronize];

        // Delete record
        [backingStore deleteRecordLocallyWithRecordID:recordID];
        [backingStore synchronize];

        NSArray *recordIDs = [backingStore recordIDsWithRecordType:@"book"];
        expect(recordIDs).to.haveCountOf(0);

        // Fetch record
        SKYRecord *fetchedRecord = [backingStore fetchRecordWithRecordID:recordID];
        expect(fetchedRecord).to.beNil();

        [backingStore revertRecordLocallyWithRecordID:recordID];
        [backingStore synchronize];

        recordIDs = [backingStore recordIDsWithRecordType:@"book"];
        expect(recordIDs).to.haveCountOf(1);
        fetchedRecord = [backingStore fetchRecordWithRecordID:recordID];
        expect(fetchedRecord[@"title"]).to.equal(record[@"title"]);
        expect(fetchedRecord.transient[@"temporary"]).to.equal(record.transient[@"temporary"]);
    });

    it(@"save overwrite local", ^{
        [backingStore saveRecord:record];
        [backingStore saveRecordLocally:localRecord];
        [backingStore synchronize];

        // Save record again also overwrite the local
        record[@"title"] = @"Bye World";
        [backingStore saveRecord:record];
        [backingStore synchronize];

        NSArray *recordIDs = [backingStore recordIDsWithRecordType:@"book"];
        expect(recordIDs).to.haveCountOf(1);
        SKYRecord *fetchedRecord = [backingStore fetchRecordWithRecordID:recordID];
        expect(fetchedRecord[@"title"]).to.equal(record[@"title"]);
        expect(fetchedRecord.transient[@"temporary"]).to.equal(record.transient[@"temporary"]);
    });

    it(@"delete overwrite local", ^{
        [backingStore saveRecord:record];
        [backingStore saveRecordLocally:localRecord];
        [backingStore synchronize];

        // Delete record overwrite the local
        [backingStore deleteRecordWithRecordID:recordID];
        [backingStore synchronize];

        NSArray *recordIDs = [backingStore recordIDsWithRecordType:@"book"];
        expect(recordIDs).to.haveCountOf(0);
        SKYRecord *fetchedRecord = [backingStore fetchRecordWithRecordID:recordID];
        expect(fetchedRecord).to.beNil();
    });

});

sharedExamples(@"SKYRecordStorageBackingStore-Query", ^(NSDictionary *data) {
    __block id<SKYRecordStorageBackingStore> backingStore;

    beforeEach(^{
        if (data[@"backingStoreFactory"]) {
            id<SKYRecordStorageBackingStore> (^factory)() = data[@"backingStoreFactory"];
            backingStore = factory();
        } else {
            backingStore = data[@"backingStore"];
        }

        SKYRecord *record;
        record = [[SKYRecord alloc]
            initWithRecordID:[SKYRecordID recordIDWithCanonicalString:@"book/id1"]
                        data:@{
                            @"title" : @"Hello World!",
                            @"order" : @(1)
                        }];
        [backingStore saveRecord:record];

        record = [[SKYRecord alloc]
            initWithRecordID:[SKYRecordID recordIDWithCanonicalString:@"book/id1"]
                        data:@{
                            @"title" : @"Bye World!",
                            @"order" : @(3)
                        }];
        [backingStore saveRecordLocally:record];

        record = [[SKYRecord alloc]
            initWithRecordID:[SKYRecordID recordIDWithCanonicalString:@"book/id2"]
                        data:@{
                            @"title" : @"Hello Island!",
                            @"order" : @(2)
                        }];
        [backingStore saveRecord:record];

        record = [[SKYRecord alloc]
            initWithRecordID:[SKYRecordID recordIDWithCanonicalString:@"note/id1"]
                        data:@{
                            @"title" : @"My note!"
                        }];
        [backingStore saveRecord:record];

        record = [[SKYRecord alloc]
            initWithRecordID:[SKYRecordID recordIDWithCanonicalString:@"note/id2"]
                        data:@{
                            @"title" : @"Your note!"
                        }];
        [backingStore saveRecord:record];
        [backingStore deleteRecordLocally:record];
        [backingStore synchronize];
    });

    it(@"simple enumerate 1", ^{
        NSMutableArray *recordIDs = [NSMutableArray array];
        [backingStore enumerateRecordsWithType:@"book"
                                     predicate:nil
                               sortDescriptors:nil
                                    usingBlock:^(SKYRecord *record, BOOL *stop) {
                                        [recordIDs addObject:record.recordID.canonicalString];
                                    }];
        expect(recordIDs).to.haveCountOf(2);
        expect(recordIDs).to.contain(@"book/id1");
        expect(recordIDs).to.contain(@"book/id2");
    });

    it(@"enumerate all", ^{
        NSMutableArray *recordIDs = [NSMutableArray array];
        [backingStore enumerateRecordsWithBlock:^(SKYRecord *record, BOOL *stop) {
            [recordIDs addObject:record.recordID.canonicalString];
        }];
        expect(recordIDs).to.haveCountOf(3);
        expect(recordIDs).to.contain(@"book/id1");
        expect(recordIDs).to.contain(@"book/id2");
        expect(recordIDs).to.contain(@"note/id1");
    });

    it(@"simple enumerate 2", ^{
        NSMutableArray *recordIDs = [NSMutableArray array];
        [backingStore enumerateRecordsWithType:@"note"
                                     predicate:nil
                               sortDescriptors:nil
                                    usingBlock:^(SKYRecord *record, BOOL *stop) {
                                        [recordIDs addObject:record.recordID.canonicalString];
                                    }];
        expect(recordIDs).to.haveCountOf(1);
        expect(recordIDs).to.contain(@"note/id1");
    });

    it(@"predicate enumerate", ^{
        NSMutableArray *recordIDs = [NSMutableArray array];
        [backingStore enumerateRecordsWithType:@"book"
                                     predicate:[NSPredicate predicateWithFormat:@"title = %@",
                                                                                @"Hello Island!"]
                               sortDescriptors:nil
                                    usingBlock:^(SKYRecord *record, BOOL *stop) {
                                        [recordIDs addObject:record.recordID.canonicalString];
                                    }];
        expect(recordIDs).to.haveCountOf(1);
        expect(recordIDs).to.contain(@"book/id2");
    });

    it(@"sorted enumerate desc", ^{
        NSMutableArray *recordIDs = [NSMutableArray array];
        [backingStore enumerateRecordsWithType:@"book"
                                     predicate:nil
                               sortDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"order"
                                                                                ascending:NO] ]
                                    usingBlock:^(SKYRecord *record, BOOL *stop) {
                                        [recordIDs addObject:record.recordID.canonicalString];
                                    }];
        expect(recordIDs).to.haveCountOf(2);
        expect(recordIDs[0]).to.contain(@"book/id1");
        expect(recordIDs[1]).to.contain(@"book/id2");
    });

    it(@"sorted enumerate asc", ^{
        NSMutableArray *recordIDs = [NSMutableArray array];
        [backingStore enumerateRecordsWithType:@"book"
                                     predicate:nil
                               sortDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"order"
                                                                                ascending:YES] ]
                                    usingBlock:^(SKYRecord *record, BOOL *stop) {
                                        [recordIDs addObject:record.recordID.canonicalString];
                                    }];
        expect(recordIDs).to.haveCountOf(2);
        expect(recordIDs[1]).to.contain(@"book/id1");
        expect(recordIDs[0]).to.contain(@"book/id2");
    });
});

SharedExamplesEnd

    SpecBegin(SKYRecordStorageMemoryStore)

        describe(@"SKYRecordStorageBackingStore-Changes", ^{
            id<SKYRecordStorageBackingStore> (^factory)() = ^id<SKYRecordStorageBackingStore>()
            {
                return [[SKYRecordStorageMemoryStore alloc] init];
            };

            NSDictionary *data = @{ @"backingStoreFactory" : factory };
            itShouldBehaveLike(@"SKYRecordStorageBackingStore-Changes", data);
            itShouldBehaveLike(@"SKYRecordStorageBackingStore-Records", data);
            itShouldBehaveLike(@"SKYRecordStorageBackingStore-Query", data);
        });

SpecEnd

    SpecBegin(SKYRecordStorageFileBackedMemoryStore)

        describe(@"SKYRecordStorageBackingStore-Changes", ^{
            id<SKYRecordStorageBackingStore> (^factory)() = ^id<SKYRecordStorageBackingStore>()
            {
                NSString *filePath = [SKYRecordStorageBackingStoreSpecTempFileProvider
                    temporaryFileWithSuffix:@"SKYRecordStorageTest.plist"];
                return [[SKYRecordStorageFileBackedMemoryStore alloc] initWithFile:filePath];
            };

            NSDictionary *data = @{ @"backingStoreFactory" : factory };
            itShouldBehaveLike(@"SKYRecordStorageBackingStore-Changes", data);
            itShouldBehaveLike(@"SKYRecordStorageBackingStore-Records", data);
            itShouldBehaveLike(@"SKYRecordStorageBackingStore-Query", data);
        });

SpecEnd

    SpecBegin(SKYRecordStorageSqliteStore)

        describe(@"SKYRecordStorageBackingStore-Changes", ^{
            id<SKYRecordStorageBackingStore> (^factory)() = ^id<SKYRecordStorageBackingStore>()
            {
                NSString *filePath = [SKYRecordStorageBackingStoreSpecTempFileProvider
                    temporaryFileWithSuffix:@"SKYRecordStorageTest.db"];
                return [[SKYRecordStorageSqliteStore alloc] initWithFile:filePath];
            };
            NSDictionary *data = @{ @"backingStoreFactory" : factory };
            itShouldBehaveLike(@"SKYRecordStorageBackingStore-Changes", data);
            itShouldBehaveLike(@"SKYRecordStorageBackingStore-Records", data);
            itShouldBehaveLike(@"SKYRecordStorageBackingStore-Query", data);
        });

SpecEnd
