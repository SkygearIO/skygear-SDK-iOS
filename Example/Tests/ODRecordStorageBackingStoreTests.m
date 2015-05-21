//
//  ODRecordStorageBackingStoreTests.m
//  ODKit
//
//  Created by atwork on 19/5/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>
#import "ODRecordSynchronizer.h"
#import "ODRecordStorageMemoryStore.h"
#import "ODRecordChange_Private.h"
#import "ODRecordStorageFileBackedMemoryStore.h"
#import "ODRecordStorageSqliteStore.h"

@interface ODRecordStorageBackingStoreSpecTempFileProvider : NSObject

+ (NSString *)temporaryFileWithSuffix:(NSString *)suffix;

@end

@implementation ODRecordStorageBackingStoreSpecTempFileProvider

+ (NSString *)temporaryFileWithSuffix:(NSString *)suffix
{
    NSString *pathComponent = [NSString stringWithFormat:@"tmpXXXXXX%@", suffix];
    NSString *tempFileTemplate = [NSTemporaryDirectory()
                                  stringByAppendingPathComponent:pathComponent];
    
    const char *tempFileTemplateCString =
    [tempFileTemplate fileSystemRepresentation];
    
    char *tempFileNameCString = (char *)malloc(strlen(tempFileTemplateCString) + 1);
    strcpy(tempFileNameCString, tempFileTemplateCString);
    int fileDescriptor = mkstemps(tempFileNameCString, (NSInteger)[suffix length]);
    
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

SharedExamplesBegin(ODRecordStorageBackingStore)

sharedExamples(@"ODRecordStorageBackingStore-Changes", ^(NSDictionary *data) {
    __block id<ODRecordStorageBackingStore> backingStore;
    
    beforeEach(^{
        if (data[@"backingStoreFactory"]) {
            id<ODRecordStorageBackingStore> (^factory)() = data[@"backingStoreFactory"];
            backingStore = factory();
        } else {
            backingStore = data[@"backingStore"];
        }
    });
    
    it(@"appending change and state changes", ^{
        ODRecordID *recordID = [[ODRecordID alloc] initWithCanonicalString:@"book/book1"];
        ODRecordChange *change;
        NSDictionary *attrs = @{
                                @"title": @[[NSNull null], @"Hello World"]
                                };
        change = [[ODRecordChange alloc] initWithRecordID:recordID
                                                   action:ODRecordChangeSave
                                            resolveMethod:ODRecordResolveByReplacing
                                         attributesToSave:attrs];
        
        // Append pending change
        [backingStore appendChange:change state:ODRecordChangeStateWaiting];
        [backingStore synchronize];
        
        expect([backingStore failedChanges]).to.haveCountOf(0);
        expect([backingStore pendingChanges]).to.haveCountOf(1);
        change = [[backingStore pendingChanges] firstObject];
        expect(change.recordID).to.equal(recordID);
        expect(change.state).to.equal(@(ODRecordChangeStateWaiting));
        
        // Get change with Record ID
        ODRecordChange *returnedChange = [backingStore changeWithRecordID:recordID];
        expect(returnedChange.state).to.equal(@(ODRecordChangeStateWaiting));
        
        // Set change to failed
        NSError *error = [NSError errorWithDomain:@"Error" code:0 userInfo:nil];
        [backingStore setFinishedStateWithError:error ofChange:change];
        [backingStore synchronize];
        
        expect([backingStore failedChanges]).to.haveCountOf(1);
        expect([backingStore pendingChanges]).to.haveCountOf(0);
        change = [[backingStore failedChanges] firstObject];
        expect(change.recordID).to.equal(recordID);
        expect(change.state).to.equal(@(ODRecordChangeStateFinished));
        expect(change.error.domain).to.equal(@"Error");
        
        // Remove the change
        [backingStore removeChange:change];
        [backingStore synchronize];
        expect([backingStore failedChanges]).to.haveCountOf(0);
        expect([backingStore pendingChanges]).to.haveCountOf(0);
    });
    
    
    it(@"two changes", ^{
        ODRecordID *recordID1 = [[ODRecordID alloc] initWithCanonicalString:@"book/book1"];
        ODRecordID *recordID2 = [[ODRecordID alloc] initWithCanonicalString:@"book/book1"];
        ODRecordChange *change1;
        ODRecordChange *change2;
        NSDictionary *attrs = @{
                                @"title": @[[NSNull null], @"Hello World"]
                                };
        change1 = [[ODRecordChange alloc] initWithRecordID:recordID1
                                                    action:ODRecordChangeSave
                                             resolveMethod:ODRecordResolveByReplacing
                                          attributesToSave:attrs];
        change2 = [[ODRecordChange alloc] initWithRecordID:recordID2
                                                    action:ODRecordChangeDelete
                                             resolveMethod:ODRecordResolveByReplacing
                                          attributesToSave:nil];
        
        // Append pending change
        [backingStore appendChange:change1 state:ODRecordChangeStateWaiting];
        [backingStore appendChange:change2 state:ODRecordChangeStateWaiting];
        [backingStore synchronize];
        
        expect([backingStore failedChanges]).to.haveCountOf(0);
        expect([backingStore pendingChanges]).to.haveCountOf(2);
        
        NSError *error = [NSError errorWithDomain:@"Error"
                                             code:0
                                         userInfo:nil];
        [backingStore setFinishedStateWithError:error ofChange:change1];
        [backingStore setFinishedStateWithError:error ofChange:change2];
        [backingStore synchronize];

        expect([backingStore failedChanges]).to.haveCountOf(2);
        expect([backingStore pendingChanges]).to.haveCountOf(0);
    });
    
});

sharedExamples(@"ODRecordStorageBackingStore-Records", ^(NSDictionary *data) {
    __block id<ODRecordStorageBackingStore> backingStore;
    __block ODRecordID *recordID;
    __block ODRecord *record;
    __block ODRecord *localRecord;
    
    beforeEach(^{
        if (data[@"backingStoreFactory"]) {
            id<ODRecordStorageBackingStore> (^factory)() = data[@"backingStoreFactory"];
            backingStore = factory();
        } else {
            backingStore = data[@"backingStore"];
        }
        recordID = [[ODRecordID alloc] initWithRecordType:@"book"];
        record = [[ODRecord alloc] initWithRecordID:recordID
                                               data:nil];
        record[@"title"] = @"Hello World";
        
        localRecord = [[ODRecord alloc] initWithRecordID:recordID
                                                    data:nil];
        localRecord[@"title"] = @"Hello World 2";
    });
    
    it(@"save, fetch, delete", ^{
        // Save record
        [backingStore saveRecord:record];
        [backingStore synchronize];
        
        NSArray *recordIDs = [backingStore queryRecordIDsWithRecordType:@"book"];
        expect(recordIDs).to.haveCountOf(1);
        
        // Fetch record
        ODRecord *fetchedRecord = [backingStore fetchRecordWithRecordID:record.recordID];
        expect(fetchedRecord[@"title"]).to.equal(record[@"title"]);
        
        // Modify record
        record[@"title"] = @"Bye World";
        [backingStore saveRecord:record];
        [backingStore synchronize];
        fetchedRecord = [backingStore fetchRecordWithRecordID:record.recordID];
        expect(fetchedRecord[@"title"]).to.equal(record[@"title"]);
        
        // Delete record
        [backingStore deleteRecord:record];
        [backingStore synchronize];
        
        recordIDs = [backingStore queryRecordIDsWithRecordType:@"book"];
        expect(recordIDs).to.haveCountOf(0);
        expect([backingStore fetchRecordWithRecordID:record.recordID]).to.beNil();
    });
    
    it(@"save, fetch, revert locally", ^{
        [backingStore saveRecord:record];
        [backingStore synchronize];

        // Save record
        [backingStore saveRecordLocally:localRecord];
        [backingStore synchronize];
        
        NSArray *recordIDs = [backingStore queryRecordIDsWithRecordType:@"book"];
        expect(recordIDs).to.haveCountOf(1);
        
        // Fetch record
        ODRecord *fetchedRecord = [backingStore fetchRecordWithRecordID:recordID];
        expect(fetchedRecord[@"title"]).to.equal(localRecord[@"title"]);
        
        // Modify local record
        localRecord[@"title"] = @"Bye World 2";
        [backingStore saveRecordLocally:localRecord];
        [backingStore synchronize];
        fetchedRecord = [backingStore fetchRecordWithRecordID:recordID];
        expect(fetchedRecord[@"title"]).to.equal(localRecord[@"title"]);

        // Revert local record
        [backingStore revertRecordLocallyWithRecordID:recordID];
        [backingStore synchronize];
        
        recordIDs = [backingStore queryRecordIDsWithRecordType:@"book"];
        expect(recordIDs).to.haveCountOf(1);
        fetchedRecord = [backingStore fetchRecordWithRecordID:recordID];
        expect(fetchedRecord[@"title"]).to.equal(record[@"title"]);
    });
    
    it(@"delete locally then revert", ^{
        [backingStore saveRecord:record];
        [backingStore synchronize];
        
        // Delete record
        [backingStore deleteRecordLocallyWithRecordID:recordID];
        [backingStore synchronize];
        
        NSArray *recordIDs = [backingStore queryRecordIDsWithRecordType:@"book"];
        expect(recordIDs).to.haveCountOf(0);
        
        // Fetch record
        ODRecord *fetchedRecord = [backingStore fetchRecordWithRecordID:recordID];
        expect(fetchedRecord).to.beNil();
        
        [backingStore revertRecordLocallyWithRecordID:recordID];
        [backingStore synchronize];
        
        recordIDs = [backingStore queryRecordIDsWithRecordType:@"book"];
        expect(recordIDs).to.haveCountOf(1);
        fetchedRecord = [backingStore fetchRecordWithRecordID:recordID];
        expect(fetchedRecord[@"title"]).to.equal(record[@"title"]);
    });
    
    it(@"save overwrite local", ^{
        [backingStore saveRecord:record];
        [backingStore saveRecordLocally:localRecord];
        [backingStore synchronize];
        
        // Save record again also overwrite the local
        record[@"title"] = @"Bye World";
        [backingStore saveRecord:record];
        [backingStore synchronize];
        
        NSArray *recordIDs = [backingStore queryRecordIDsWithRecordType:@"book"];
        expect(recordIDs).to.haveCountOf(1);
        ODRecord *fetchedRecord = [backingStore fetchRecordWithRecordID:recordID];
        expect(fetchedRecord[@"title"]).to.equal(record[@"title"]);
    });
    
    it(@"delete overwrite local", ^{
        [backingStore saveRecord:record];
        [backingStore saveRecordLocally:localRecord];
        [backingStore synchronize];
        
        // Delete record overwrite the local
        [backingStore deleteRecordWithRecordID:recordID];
        [backingStore synchronize];
        
        NSArray *recordIDs = [backingStore queryRecordIDsWithRecordType:@"book"];
        expect(recordIDs).to.haveCountOf(0);
        ODRecord *fetchedRecord = [backingStore fetchRecordWithRecordID:recordID];
        expect(fetchedRecord).to.beNil();
    });
    
});

SharedExamplesEnd

SpecBegin(ODRecordStorageMemoryStore)

describe(@"ODRecordStorageBackingStore-Changes", ^{
    id<ODRecordStorageBackingStore> (^factory)() = ^id<ODRecordStorageBackingStore>() {
        return [[ODRecordStorageMemoryStore alloc] init];
    };

    NSDictionary *data = @{
                           @"backingStoreFactory": factory
                           };
    itShouldBehaveLike(@"ODRecordStorageBackingStore-Changes", data);
    itShouldBehaveLike(@"ODRecordStorageBackingStore-Records", data);
});

SpecEnd

SpecBegin(ODRecordStorageFileBackedMemoryStore)

describe(@"ODRecordStorageBackingStore-Changes", ^{
    id<ODRecordStorageBackingStore> (^factory)() = ^id<ODRecordStorageBackingStore>() {
        NSString *filePath = [ODRecordStorageBackingStoreSpecTempFileProvider
                              temporaryFileWithSuffix:@"ODRecordStorageTest.plist"];
        return [[ODRecordStorageFileBackedMemoryStore alloc] initWithFile:filePath];
    };

    NSDictionary *data = @{
                           @"backingStoreFactory": factory
                           };
    itShouldBehaveLike(@"ODRecordStorageBackingStore-Changes", data);
    itShouldBehaveLike(@"ODRecordStorageBackingStore-Records", data);
});

SpecEnd

SpecBegin(ODRecordStorageSqliteStore)

describe(@"ODRecordStorageBackingStore-Changes", ^{
    id<ODRecordStorageBackingStore> (^factory)() = ^id<ODRecordStorageBackingStore>() {
        NSString *filePath = [ODRecordStorageBackingStoreSpecTempFileProvider
                              temporaryFileWithSuffix:@"ODRecordStorageTest.db"];
        return [[ODRecordStorageSqliteStore alloc] initWithFile:filePath];
    };
    NSDictionary *data = @{
                           @"backingStoreFactory": factory
                           };
    itShouldBehaveLike(@"ODRecordStorageBackingStore-Changes", data);
    itShouldBehaveLike(@"ODRecordStorageBackingStore-Records", data);
});

SpecEnd
