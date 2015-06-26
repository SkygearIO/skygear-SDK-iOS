//
//  ODRecordStorageTests.m
//  ODKit
//
//  Created by atwork on 7/5/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <ODKit/ODKit.h>
#import "ODRecordStorageMemoryStore.h"
#import "ODRecordSynchronizer.h"

SpecBegin(ODRecordStorage)

describe(@"ODRecordStorage", ^{
    __block ODRecordStorage *storage = nil;
    
    beforeEach(^{
        storage = [[ODRecordStorage alloc] initWithBackingStore:[[ODRecordStorageMemoryStore alloc] init]];
    });

    it(@"init", ^{
        expect([storage class]).to.equal([ODRecordStorage class]);
    });
    
    it(@"fetch, save, delete", ^{
        // save
        ODRecord *record = [[ODRecord alloc] initWithRecordType:@"book"];
        record[@"title"] = @"Hello World!";
        [storage saveRecord:record];
        
        // fetch
        ODRecord *gotRecord = [storage recordWithRecordID:record.recordID];
        expect(gotRecord).to.beIdenticalTo(record);

        // delete
        [storage deleteRecord:gotRecord];
        expect([storage recordWithRecordID:record.recordID]).to.beNil();
    });
    
    it(@"save record then delete should override previous change", ^{
        // save
        ODRecord *record = [[ODRecord alloc] initWithRecordType:@"book"];
        record[@"title"] = @"Hello World!";
        [storage saveRecord:record];
        
        // delete
        [storage deleteRecord:record];
        
        expect([storage pendingChanges]).to.haveCountOf(1);
        ODRecordChange *change = [[storage pendingChanges] firstObject];
        expect(change.action).to.equal(ODRecordChangeDelete);
    });
    
    it(@"delete record then save should override previous change", ^{
        ODRecord *record = [[ODRecord alloc] initWithRecordType:@"book"];
        record[@"title"] = @"Hello World!";
        [storage beginUpdating];
        [storage updateByReplacingWithRecords:@[record]];
        [storage finishUpdating];

        [storage deleteRecord:record];
        
        ODRecord *anotherRecord = [[ODRecord alloc] initWithRecordID:record.recordID
                                                                data:record.dictionary];
        [storage saveRecord:anotherRecord];
        expect([storage pendingChanges]).to.haveCountOf(1);
        ODRecordChange *change = [[storage pendingChanges] firstObject];
        expect(change.action).to.equal(ODRecordChangeSave);
    });
    
    it(@"save record will add to pending changes", ^{
        // save
        ODRecord *record = [[ODRecord alloc] initWithRecordType:@"book"];
        record[@"title"] = @"Hello World!";
        [storage saveRecord:record];
        
        expect(storage.pendingChanges).to.haveCountOf(1);
    });
    
    it(@"dismiss changes will remove pending changes", ^{
        // save
        ODRecord *record = [[ODRecord alloc] initWithRecordType:@"book"];
        record[@"title"] = @"Hello World!";
        [storage saveRecord:record];
        expect(storage.pendingChanges).to.haveCountOf(1);
        
        [storage dismissChange:storage.pendingChanges[0] error:nil];
        expect(storage.pendingChanges).to.haveCountOf(0);
    });
    
    it(@"query records", ^{
        // save
        ODRecord *record = [[ODRecord alloc] initWithRecordType:@"book"];
        record[@"title"] = @"Hello World!";
        [storage saveRecord:record];
        
        NSArray *records = [storage recordsWithType:@"book"
                                          predicate:nil
                                    sortDescriptors:nil];
        expect(records).to.haveCountOf(1);
        expect(((ODRecord *)records[0]).recordID).to.equal(record.recordID);
    });

    it(@"call synchronizer when enabled", ^{
        ODRecordSynchronizer *mockSyncher = OCMClassMock([ODRecordSynchronizer class]);
        storage.synchronizer = mockSyncher;
        
        storage.enabled = YES;
        
        OCMVerify([mockSyncher recordStorageFetchUpdates:storage completionHandler:[OCMArg any]]);
    });
    
    it(@"call synchronizer when saving", ^{
        storage.enabled = YES;
        
        ODRecordSynchronizer *mockSyncher = OCMClassMock([ODRecordSynchronizer class]);
        storage.synchronizer = mockSyncher;
        
        ODRecord *record = [[ODRecord alloc] initWithRecordType:@"book"];
        [storage saveRecord:record];
        
        OCMStub([mockSyncher recordStorage:storage
                               saveChanges:[OCMArg checkWithBlock:^BOOL(id obj) {
            expect([obj class]).to.beSubclassOf([NSArray class]);
            expect(obj).to.haveCountOf(1);
            ODRecordChange *change = [obj objectAtIndex:0];
            expect([change class]).to.beSubclassOf([ODRecordChange class]);
            expect(change.recordID).to.equal(record.recordID);
            return YES;
        }] completionHandler:nil]);
        
        OCMVerify([mockSyncher recordStorage:storage saveChanges:[OCMArg any] completionHandler:nil]);
    });
    
    it(@"update by replacing", ^{
        // NOTE: Currently there does not exist facility to add records to backing store.
        // Therefore, we do this by calling -updateByReplacingWithRecords:, which is the same
        // method we have to test in this test case.
        ODRecord *record = [[ODRecord alloc] initWithRecordType:@"book"];
        record[@"title"] = @"Hello World";
        ODRecord *recordToDelete = [[ODRecord alloc] initWithRecordType:@"book"];
        record[@"title"] = @"Bye World";
        [storage beginUpdating];
        [storage updateByReplacingWithRecords:@[record, recordToDelete]];
        [storage finishUpdating];
        
        ODRecord *recordToChange = [record copy];
        recordToChange[@"title"] = @"Hello World Second Edition";

        ODRecord *recordToAdd = [[ODRecord alloc] initWithRecordType:@"book"];
        recordToAdd[@"title"] = @"Welcome World";

        [storage beginUpdating];
        [storage updateByReplacingWithRecords:@[recordToChange, recordToAdd]];
        [storage finishUpdating];
        
        NSArray *records = [storage recordsWithType:@"book"];
        expect(records).to.haveCountOf(2);
        NSArray *recordIDs = @[
                               ((ODRecord *)records[0]).recordID,
                               ((ODRecord *)records[1]).recordID,
                               ];
        expect(recordIDs).to.contain(recordToAdd.recordID);
        expect(recordIDs).to.contain(recordToChange.recordID);
        
        ODRecord *changedRecord = [storage recordWithRecordID:recordToChange.recordID];
        expect(changedRecord[@"title"]).to.equal(recordToChange[@"title"]);
    });
    
    it(@"update by applying change", ^{
        ODRecord *record = [[ODRecord alloc] initWithRecordType:@"book"];
        record[@"title"] = @"Hello World";
        [storage beginUpdating];
        [storage updateByReplacingWithRecords:@[record]];
        [storage finishUpdating];
        
        ODRecord *recordToChange = [record copy];
        recordToChange[@"title"] = @"Hello World Second Edition";
        
        [storage saveRecord:recordToChange];
        
        ODRecordChange *change = [[storage pendingChanges] firstObject];
        
        [storage beginUpdating];
        [storage updateByApplyingChange:change
                         recordOnRemote:[recordToChange copy]
                                  error:nil];
        [storage finishUpdating];
        
        ODRecord *changedRecord = [storage recordWithRecordID:recordToChange.recordID];
        expect(changedRecord[@"title"]).to.equal(recordToChange[@"title"]);
    });
    
    it(@"record state", ^{
        ODRecord *record = [[ODRecord alloc] initWithRecordType:@"book"];
        record[@"title"] = @"Hello World";
        [storage beginUpdating];
        [storage updateByReplacingWithRecords:@[record]];
        [storage finishUpdating];
        expect([storage recordStateWithRecord:record]).to.equal(ODRecordStateSynchronized);

        record[@"title"] = @"Hello World 2";
        [storage saveRecord:record];
        expect([storage recordStateWithRecord:record]).to.equal(ODRecordStateNotSynchronized);
    });

    it(@"record state synchronizing", ^{
        ODRecordSynchronizer *mockSyncher = OCMClassMock([ODRecordSynchronizer class]);
        storage.synchronizer = mockSyncher;
        
        ODRecord *record = [[ODRecord alloc] initWithRecordType:@"book"];
        record[@"title"] = @"Hello World";
        [storage saveRecord:record];
        
        OCMStub([mockSyncher isProcessingChange:[OCMArg any] storage:storage]).andReturn(YES);
        expect([storage recordStateWithRecord:record]).to.equal(ODRecordStateSynchronizing);
    });
});

SpecEnd