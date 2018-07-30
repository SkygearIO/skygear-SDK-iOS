//
//  SKYRecordSynchronizerTests.m
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
#import <SKYKit/SKYKit.h>

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

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
            id<SKYRecordStorageBackingStore> backingStore =
                [[SKYRecordStorageMemoryStore alloc] init];
            storage = OCMPartialMock([[SKYRecordStorage alloc] initWithBackingStore:backingStore]);
            existingRecord = [[SKYRecord alloc] initWithType:@"book"];
            [storage beginUpdating];
            [storage updateByReplacingWithRecords:@[ existingRecord ]];
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
            SKYRecord *record = [[SKYRecord alloc] initWithType:@"book"];
            OCMStub([database executeOperation:[OCMArg checkWithBlock:^BOOL(id obj) {
                                  expect([obj class]).to.beSubclassOf([SKYQueryOperation class]);

                                  SKYQueryOperation *op = obj;
                                  if (op.perRecordCompletionBlock) {
                                      op.perRecordCompletionBlock(record);
                                  }
                                  if (op.queryRecordsCompletionBlock) {
                                      op.queryRecordsCompletionBlock(@[ record ], nil, nil);
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
            OCMStub([database
                executeOperation:[OCMArg checkWithBlock:^BOOL(id obj) {
                    expect([obj class]).to.beSubclassOf([SKYModifyRecordsOperation class]);

                    SKYModifyRecordsOperation *op = obj;
                    if (op.perRecordCompletionBlock) {
                        op.perRecordCompletionBlock(record, nil);
                    }
                    if (op.modifyRecordsCompletionBlock) {
                        op.modifyRecordsCompletionBlock(@[ record ], nil);
                    }
                    return YES;
                }]]);

            [storage saveRecord:record];
            SKYRecordChange *change = [[storage pendingChanges] firstObject];

            OCMStub([storage updateByApplyingChange:change recordOnRemote:record error:nil]);

            [synchronizer recordStorage:storage saveChanges:@[ change ] completionHandler:nil];

            OCMVerify([database executeOperation:[OCMArg any]]);
            [(id)storage setExpectationOrderMatters:YES];
            OCMVerify([storage beginUpdating]);
            OCMVerify([storage updateByApplyingChange:change recordOnRemote:record error:nil]);
            OCMVerify([storage finishUpdating]);
        });

        it(@"apply change for delete", ^{
            SKYRecord *record = [[SKYRecord alloc] initWithType:@"book"];
            OCMStub([database
                executeOperation:[OCMArg checkWithBlock:^BOOL(id obj) {
                    expect([obj class]).to.beSubclassOf([SKYDeleteRecordsOperation class]);

                    SKYDeleteRecordsOperation *op = obj;
                    if (op.perRecordCompletionBlock) {
                        op.perRecordCompletionBlock(record.recordType, record.recordID, nil);
                    }
                    if (op.deleteRecordsCompletionBlock) {
                        op.deleteRecordsCompletionBlock(@[ record.recordType ],
                                                        @[ record.recordID ], nil);
                    }
                    return YES;
                }]]);

            [storage deleteRecord:existingRecord];
            SKYRecordChange *change = [[storage pendingChanges] firstObject];

            OCMStub([storage updateByApplyingChange:change recordOnRemote:nil error:nil]);

            [synchronizer recordStorage:storage saveChanges:@[ change ] completionHandler:nil];

            OCMVerify([database executeOperation:[OCMArg any]]);
            [(id)storage setExpectationOrderMatters:YES];
            OCMVerify([storage beginUpdating]);
            OCMVerify([storage updateByApplyingChange:change recordOnRemote:nil error:nil]);
            OCMVerify([storage finishUpdating]);
        });
    });

SpecEnd

#pragma GCC diagnostic pop
