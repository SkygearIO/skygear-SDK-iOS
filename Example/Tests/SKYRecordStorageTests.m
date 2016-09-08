//
//  SKYRecordStorageTests.m
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

#import "SKYRecordStorageMemoryStore.h"
#import "SKYRecordSynchronizer.h"
#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <SKYKit/SKYKit.h>

SpecBegin(SKYRecordStorage)

    describe(@"SKYRecordStorage", ^{
        __block SKYRecordStorage *storage = nil;

        beforeEach(^{
            storage = [[SKYRecordStorage alloc]
                initWithBackingStore:[[SKYRecordStorageMemoryStore alloc] init]];
        });

        it(@"init", ^{
            expect([storage class]).to.equal([SKYRecordStorage class]);
        });

        it(@"fetch, save, delete", ^{
            // save
            SKYRecord *record = [[SKYRecord alloc] initWithRecordType:@"book"];
            record[@"title"] = @"Hello World!";
            [storage saveRecord:record];

            expect(record.creationDate).toNot.beNil();
            expect(record.modificationDate).toNot.beNil();

            // fetch
            SKYRecord *gotRecord = [storage recordWithRecordID:record.recordID];
            expect(gotRecord).to.beIdenticalTo(record);

            // delete
            [storage deleteRecord:gotRecord];
            expect([storage recordWithRecordID:record.recordID]).to.beNil();
        });

        it(@"save record then delete should override previous change", ^{
            // save
            SKYRecord *record = [[SKYRecord alloc] initWithRecordType:@"book"];
            record[@"title"] = @"Hello World!";
            [storage saveRecord:record];

            // delete
            [storage deleteRecord:record];

            expect([storage pendingChanges]).to.haveCountOf(1);
            SKYRecordChange *change = [[storage pendingChanges] firstObject];
            expect(change.action).to.equal(SKYRecordChangeDelete);
        });

        it(@"delete record then save should override previous change", ^{
            SKYRecord *record = [[SKYRecord alloc] initWithRecordType:@"book"];
            record[@"title"] = @"Hello World!";
            [storage beginUpdating];
            [storage updateByReplacingWithRecords:@[ record ]];
            [storage finishUpdating];

            [storage deleteRecord:record];

            SKYRecord *anotherRecord =
                [[SKYRecord alloc] initWithRecordID:record.recordID data:record.dictionary];
            [storage saveRecord:anotherRecord];
            expect([storage pendingChanges]).to.haveCountOf(1);
            SKYRecordChange *change = [[storage pendingChanges] firstObject];
            expect(change.action).to.equal(SKYRecordChangeSave);
        });

        it(@"save record will add to pending changes", ^{
            // save
            SKYRecord *record = [[SKYRecord alloc] initWithRecordType:@"book"];
            record[@"title"] = @"Hello World!";
            [storage saveRecord:record];

            expect(storage.pendingChanges).to.haveCountOf(1);
        });

        it(@"dismiss changes will remove pending changes", ^{
            // save
            SKYRecord *record = [[SKYRecord alloc] initWithRecordType:@"book"];
            record[@"title"] = @"Hello World!";
            [storage saveRecord:record];
            expect(storage.pendingChanges).to.haveCountOf(1);

            [storage dismissChange:storage.pendingChanges[0] error:nil];
            expect(storage.pendingChanges).to.haveCountOf(0);
        });

        it(@"query records", ^{
            // save
            SKYRecord *record = [[SKYRecord alloc] initWithRecordType:@"book"];
            record[@"title"] = @"Hello World!";
            [storage saveRecord:record];

            NSArray *records = [storage recordsWithType:@"book" predicate:nil sortDescriptors:nil];
            expect(records).to.haveCountOf(1);
            expect(((SKYRecord *)records[0]).recordID).to.equal(record.recordID);
        });

        it(@"call synchronizer when enabled", ^{
            SKYRecordSynchronizer *mockSyncher = OCMClassMock([SKYRecordSynchronizer class]);
            storage.synchronizer = mockSyncher;

            storage.enabled = YES;

            OCMVerify(
                [mockSyncher recordStorageFetchUpdates:storage completionHandler:[OCMArg any]]);
        });

        it(@"call synchronizer when saving", ^{
            storage.enabled = YES;

            SKYRecordSynchronizer *mockSyncher = OCMClassMock([SKYRecordSynchronizer class]);
            storage.synchronizer = mockSyncher;

            SKYRecord *record = [[SKYRecord alloc] initWithRecordType:@"book"];
            [storage saveRecord:record];

            OCMStub([mockSyncher
                    recordStorage:storage
                      saveChanges:[OCMArg checkWithBlock:^BOOL(id obj) {
                          expect([obj class]).to.beSubclassOf([NSArray class]);
                          expect(obj).to.haveCountOf(1);
                          SKYRecordChange *change = [obj objectAtIndex:0];
                          expect([change class]).to.beSubclassOf([SKYRecordChange class]);
                          expect(change.recordID).to.equal(record.recordID);
                          return YES;
                      }]
                completionHandler:nil]);

            OCMVerify(
                [mockSyncher recordStorage:storage saveChanges:[OCMArg any] completionHandler:nil]);
        });

        it(@"update by replacing", ^{
            // NOTE: Currently there does not exist facility to add records to backing store.
            // Therefore, we do this by calling -updateByReplacingWithRecords:, which is the same
            // method we have to test in this test case.
            SKYRecord *record = [[SKYRecord alloc] initWithRecordType:@"book"];
            record[@"title"] = @"Hello World";
            SKYRecord *recordToDelete = [[SKYRecord alloc] initWithRecordType:@"book"];
            record[@"title"] = @"Bye World";
            [storage beginUpdating];
            [storage updateByReplacingWithRecords:@[ record, recordToDelete ]];
            [storage finishUpdating];

            SKYRecord *recordToChange = [record copy];
            recordToChange[@"title"] = @"Hello World Second Edition";

            SKYRecord *recordToAdd = [[SKYRecord alloc] initWithRecordType:@"book"];
            recordToAdd[@"title"] = @"Welcome World";

            [storage beginUpdating];
            [storage updateByReplacingWithRecords:@[ recordToChange, recordToAdd ]];
            [storage finishUpdating];

            NSArray *records = [storage recordsWithType:@"book"];
            expect(records).to.haveCountOf(2);
            NSArray *recordIDs = @[
                ((SKYRecord *)records[0]).recordID,
                ((SKYRecord *)records[1]).recordID,
            ];
            expect(recordIDs).to.contain(recordToAdd.recordID);
            expect(recordIDs).to.contain(recordToChange.recordID);

            SKYRecord *changedRecord = [storage recordWithRecordID:recordToChange.recordID];
            expect(changedRecord[@"title"]).to.equal(recordToChange[@"title"]);
        });

        it(@"update by applying change", ^{
            SKYRecord *record = [[SKYRecord alloc] initWithRecordType:@"book"];
            record[@"title"] = @"Hello World";
            [storage beginUpdating];
            [storage updateByReplacingWithRecords:@[ record ]];
            [storage finishUpdating];

            SKYRecord *recordToChange = [record copy];
            recordToChange[@"title"] = @"Hello World Second Edition";

            [storage saveRecord:recordToChange];

            SKYRecordChange *change = [[storage pendingChanges] firstObject];

            [storage beginUpdating];
            [storage updateByApplyingChange:change recordOnRemote:[recordToChange copy] error:nil];
            [storage finishUpdating];

            SKYRecord *changedRecord = [storage recordWithRecordID:recordToChange.recordID];
            expect(changedRecord[@"title"]).to.equal(recordToChange[@"title"]);
        });

        it(@"record state", ^{
            SKYRecord *record = [[SKYRecord alloc] initWithRecordType:@"book"];
            record[@"title"] = @"Hello World";
            [storage beginUpdating];
            [storage updateByReplacingWithRecords:@[ record ]];
            [storage finishUpdating];
            expect([storage recordStateWithRecord:record]).to.equal(SKYRecordStateSynchronized);

            record[@"title"] = @"Hello World 2";
            [storage saveRecord:record];
            expect([storage recordStateWithRecord:record]).to.equal(SKYRecordStateNotSynchronized);
        });

        it(@"record state synchronizing", ^{
            SKYRecordSynchronizer *mockSyncher = OCMClassMock([SKYRecordSynchronizer class]);
            storage.synchronizer = mockSyncher;

            SKYRecord *record = [[SKYRecord alloc] initWithRecordType:@"book"];
            record[@"title"] = @"Hello World";
            [storage saveRecord:record];

            OCMStub([mockSyncher isProcessingChange:[OCMArg any] storage:storage]).andReturn(YES);
            expect([storage recordStateWithRecord:record]).to.equal(SKYRecordStateSynchronizing);
        });
    });

SpecEnd
