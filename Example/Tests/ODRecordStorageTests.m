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
    
    it(@"pending changes", ^{
        // save
        ODRecord *record = [[ODRecord alloc] initWithRecordType:@"book"];
        record[@"title"] = @"Hello World!";
        [storage saveRecord:record];
        
        expect(storage.pendingChanges).to.haveCountOf(1);
        
        storage.enabled = YES;
        
        // FIXME This assumes the storage to be using memory store.
        expect(storage.pendingChanges).to.haveCountOf(0);
    });
    
    it(@"dismiss changes", ^{
        // save
        ODRecord *record = [[ODRecord alloc] initWithRecordType:@"book"];
        record[@"title"] = @"Hello World!";
        [storage saveRecord:record];
        expect(storage.pendingChanges).to.haveCountOf(1);
        
        [storage dismissChange:storage.pendingChanges[0] error:nil];
        expect(storage.pendingChanges).to.haveCountOf(0);
    });
});

SpecEnd