//
//  ODRecordSynchronizerTests.m
//  ODKit
//
//  Created by atwork on 13/5/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>
#import "ODRecordSynchronizer.h"
#import "ODRecordStorageMemoryStore.h"

SpecBegin(ODRecordSynchronizer)

describe(@"ODRecordSynchronizer for query", ^{
    __block ODContainer *container;
    __block ODDatabase *database;
    __block ODRecordSynchronizer *synchronizer;
    __block ODRecordStorage *storage;
    __block ODRecord *existingRecord;

    
    beforeEach(^{
        container = [ODContainer defaultContainer];
        database = OCMPartialMock([container privateCloudDatabase]);
        ODQuery *query = [[ODQuery alloc] initWithRecordType:@"book" predicate:nil];
        synchronizer = [[ODRecordSynchronizer alloc] initWithContainer:container
                                                              database:database
                                                                 query:query];
        id<ODRecordStorageBackingStore> backingStore = [[ODRecordStorageMemoryStore alloc] init];
        storage = OCMPartialMock([[ODRecordStorage alloc] initWithBackingStore:backingStore]);
        existingRecord = [[ODRecord alloc] initWithRecordType:@"book"];
        [storage beginUpdating];
        [storage updateByReplacingWithRecords:@[existingRecord]];
        [storage finishUpdating];
    });
    
    afterEach(^{
        [(id)database stopMocking];
        [(id)storage stopMocking];
    });
    
    it(@"init", ^{
        expect([synchronizer class]).to.beSubclassOf([ODRecordSynchronizer class]);
    });
    
    it(@"fetch updates", ^{
        ODRecord *record = [[ODRecord alloc] initWithRecordType:@"book"];
        OCMStub([database executeOperation:[OCMArg checkWithBlock:^BOOL(id obj) {
            expect([obj class]).to.beSubclassOf([ODQueryOperation class]);
            
            ODQueryOperation *op = obj;
            if (op.perRecordCompletionBlock) {
                op.perRecordCompletionBlock(record);
            }
            if (op.queryRecordsCompletionBlock) {
                op.queryRecordsCompletionBlock(@[record], nil, nil);
            }
            return YES;
        }]]);
        OCMStub([storage updateByReplacingWithRecords:[OCMArg checkWithBlock:^BOOL(id obj) {
            expect([obj class]).to.beSubclassOf([NSArray class]);
            expect([obj objectAtIndex:0]).to.equal(record);
            return YES;
        }]]);
        
        [synchronizer recordStorageFetchUpdates:storage];
        
        OCMVerify([database executeOperation:[OCMArg any]]);
        [(id)storage setExpectationOrderMatters:YES];
        OCMVerify([storage beginUpdating]);
        OCMVerify([storage updateByReplacingWithRecords:[OCMArg any]]);
        OCMVerify([storage finishUpdating]);
    });
    
    it(@"apply change for save", ^{
        ODRecord *record = [existingRecord copy];
        record[@"title"] = @"Hello World";
        OCMStub([database executeOperation:[OCMArg checkWithBlock:^BOOL(id obj) {
            expect([obj class]).to.beSubclassOf([ODModifyRecordsOperation class]);
            
            ODModifyRecordsOperation *op = obj;
            if (op.perRecordCompletionBlock) {
                op.perRecordCompletionBlock(record, nil);
            }
            if (op.modifyRecordsCompletionBlock) {
                op.modifyRecordsCompletionBlock(@[record], nil);
            }
            return YES;
        }]]);
        
        [storage saveRecord:record];
        ODRecordChange *change = [[storage pendingChanges] firstObject];
        
        OCMStub([storage updateByApplyingChange:change recordOnRemote:record error:nil]);
        
        [synchronizer recordStorage:storage
                        saveChanges:@[change]];
        
        OCMVerify([database executeOperation:[OCMArg any]]);
        [(id)storage setExpectationOrderMatters:YES];
        OCMVerify([storage beginUpdating]);
        OCMVerify([storage updateByApplyingChange:change recordOnRemote:record error:nil]);
        OCMVerify([storage finishUpdating]);
    });
    
    it(@"apply change for delete", ^{
        ODRecord *record = [[ODRecord alloc] initWithRecordType:@"book"];
        OCMStub([database executeOperation:[OCMArg checkWithBlock:^BOOL(id obj) {
            expect([obj class]).to.beSubclassOf([ODDeleteRecordsOperation class]);
            
            ODDeleteRecordsOperation *op = obj;
            if (op.perRecordCompletionBlock) {
                op.perRecordCompletionBlock(record.recordID, nil);
            }
            if (op.deleteRecordsCompletionBlock) {
                op.deleteRecordsCompletionBlock(@[record.recordID], nil);
            }
            return YES;
        }]]);
        
        [storage deleteRecord:existingRecord];
        ODRecordChange *change = [[storage pendingChanges] firstObject];
        
        OCMStub([storage updateByApplyingChange:change recordOnRemote:nil error:nil]);
        
        [synchronizer recordStorage:storage
                        saveChanges:@[change]];
        
        OCMVerify([database executeOperation:[OCMArg any]]);
        [(id)storage setExpectationOrderMatters:YES];
        OCMVerify([storage beginUpdating]);
        OCMVerify([storage updateByApplyingChange:change recordOnRemote:nil error:nil]);
        OCMVerify([storage finishUpdating]);
    });
});

SpecEnd