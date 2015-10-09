//
//  SKYRecordSynchronizerTests.m
//  SkyKit
//
//  Created by atwork on 13/5/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SkyKit/SkyKit.h>
#import "SKYRecordSynchronizer.h"
#import "SKYRecordStorageMemoryStore.h"

SpecBegin(SKYRecordSynchronizer)

describe(@"SKYRecordSynchronizer for query", ^{
    __block SKYContainer *container;
    __block SKYDatabase *database;
    __block SKYRecordSynchronizer *synchronizer;
    __block SKYRecordStorage *storage;
    __block SKYRecord *existingRecord;

    
    beforeEach(^{
        container = [SKYContainer defaultContainer];
        database = OCMPartialMock([container privateCloudDatabase]);
        SKYQuery *query = [[SKYQuery alloc] initWithRecordType:@"book" predicate:nil];
        synchronizer = [[SKYRecordSynchronizer alloc] initWithContainer:container
                                                              database:database
                                                                 query:query];
        id<SKYRecordStorageBackingStore> backingStore = [[SKYRecordStorageMemoryStore alloc] init];
        storage = OCMPartialMock([[SKYRecordStorage alloc] initWithBackingStore:backingStore]);
        existingRecord = [[SKYRecord alloc] initWithRecordType:@"book"];
        [storage beginUpdating];
        [storage updateByReplacingWithRecords:@[existingRecord]];
        [storage finishUpdating];
    });
    
    afterEach(^{
        [(id)database stopMocking];
        [(id)storage stopMocking];
    });
    
    it(@"init", ^{
        expect([synchronizer class]).to.beSubclassOf([SKYRecordSynchronizer class]);
    });
    
    it(@"fetch updates", ^{
        SKYRecord *record = [[SKYRecord alloc] initWithRecordType:@"book"];
        OCMStub([database executeOperation:[OCMArg checkWithBlock:^BOOL(id obj) {
            expect([obj class]).to.beSubclassOf([SKYQueryOperation class]);
            
            SKYQueryOperation *op = obj;
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
        
        [synchronizer recordStorageFetchUpdates:storage completionHandler:nil];
        
        OCMVerify([database executeOperation:[OCMArg any]]);
        [(id)storage setExpectationOrderMatters:YES];
        OCMVerify([storage beginUpdating]);
        OCMVerify([storage updateByReplacingWithRecords:[OCMArg any]]);
        OCMVerify([storage finishUpdating]);
    });
    
    it(@"apply change for save", ^{
        SKYRecord *record = [existingRecord copy];
        record[@"title"] = @"Hello World";
        OCMStub([database executeOperation:[OCMArg checkWithBlock:^BOOL(id obj) {
            expect([obj class]).to.beSubclassOf([SKYModifyRecordsOperation class]);
            
            SKYModifyRecordsOperation *op = obj;
            if (op.perRecordCompletionBlock) {
                op.perRecordCompletionBlock(record, nil);
            }
            if (op.modifyRecordsCompletionBlock) {
                op.modifyRecordsCompletionBlock(@[record], nil);
            }
            return YES;
        }]]);
        
        [storage saveRecord:record];
        SKYRecordChange *change = [[storage pendingChanges] firstObject];
        
        OCMStub([storage updateByApplyingChange:change recordOnRemote:record error:nil]);
        
        [synchronizer recordStorage:storage
                        saveChanges:@[change]
                  completionHandler:nil];
        
        OCMVerify([database executeOperation:[OCMArg any]]);
        [(id)storage setExpectationOrderMatters:YES];
        OCMVerify([storage beginUpdating]);
        OCMVerify([storage updateByApplyingChange:change recordOnRemote:record error:nil]);
        OCMVerify([storage finishUpdating]);
    });
    
    it(@"apply change for delete", ^{
        SKYRecord *record = [[SKYRecord alloc] initWithRecordType:@"book"];
        OCMStub([database executeOperation:[OCMArg checkWithBlock:^BOOL(id obj) {
            expect([obj class]).to.beSubclassOf([SKYDeleteRecordsOperation class]);
            
            SKYDeleteRecordsOperation *op = obj;
            if (op.perRecordCompletionBlock) {
                op.perRecordCompletionBlock(record.recordID, nil);
            }
            if (op.deleteRecordsCompletionBlock) {
                op.deleteRecordsCompletionBlock(@[record.recordID], nil);
            }
            return YES;
        }]]);
        
        [storage deleteRecord:existingRecord];
        SKYRecordChange *change = [[storage pendingChanges] firstObject];
        
        OCMStub([storage updateByApplyingChange:change recordOnRemote:nil error:nil]);
        
        [synchronizer recordStorage:storage
                        saveChanges:@[change]
                  completionHandler:nil];
        
        OCMVerify([database executeOperation:[OCMArg any]]);
        [(id)storage setExpectationOrderMatters:YES];
        OCMVerify([storage beginUpdating]);
        OCMVerify([storage updateByApplyingChange:change recordOnRemote:nil error:nil]);
        OCMVerify([storage finishUpdating]);
    });
});

SpecEnd
