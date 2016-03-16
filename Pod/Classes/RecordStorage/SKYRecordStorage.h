//
//  SKYRecordStorage.h
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

#import <Foundation/Foundation.h>

#import "SKYNotification.h"
#import "SKYRecord.h"
#import "SKYRecordChange.h"
#import "SKYRecordStorageBackingStore.h"

extern NSString *const SKYRecordStorageDidUpdateNotification;
extern NSString *const SKYRecordStorageWillSynchronizeChangesNotification;
extern NSString *const SKYRecordStorageDidSynchronizeChangesNotification;
extern NSString *const SKYRecordStorageUpdateAvailableNotification;
extern NSString *const SKYRecordStoragePendingChangesCountKey;
extern NSString *const SKYRecordStorageFailedChangesCountKey;
extern NSString *const SKYRecordStorageSavedRecordIDsKey;
extern NSString *const SKYRecordStorageDeletedRecordIDsKey;

@class SKYRecordSynchronizer;

typedef enum : NSInteger {
    /**
     Record is in the same state as the last known state on server.
     */
    SKYRecordStateSynchronized,

    /**
     Record is changed locally and is yet to be saved on server.
     */
    SKYRecordStateNotSynchronized,

    /**
     Record is changed locally and is yet to be saved on server.
     */
    SKYRecordStateSynchronizing,

    /**
     Record is in a state that is in conflict with the state on server.
     */
    SKYRecordStateConflicted,
} SKYRecordState;

/**
 <SKYRecordStorage> provides a local storage for records that is synchronized
 with a subset of records on remote server. Changes made remotely are
 reflected on the local storage and vice versa.

 This class is useful for applications in which records are available
 offline, and that user may modify data when device is offline to
 have changes uploaded to remote server when device becomes online again.

 User should not instantiate an instance of this class directly. An
 instance of <SKYRecordStorage> should be obtained from
 <SKYRecordStorageCoordinator>.
 */
@interface SKYRecordStorage : NSObject

/**
 Returns whether the <SKYRecordStorage> should synchronizes changes
 from remote to local and vice versa.

 When this is YES, any pending changes will be performed at an appropriate
 time. When this is set to NO, any changes will be kept in pending state
 until this is set to YES again.
 */
@property (nonatomic, assign) BOOL enabled;

/**
 Returns whether the <SKYRecordStorage> is currently updating the backing store.

 When the backing store is being updated, calling -beginUpdating is not allowed.
 */
@property (nonatomic, readonly, getter=isUpdating) BOOL updating;

/**
 Returns the backing store object used to initialize the the storage.
 */
@property (nonatomic, readonly, strong) id<SKYRecordStorageBackingStore> backingStore;

/**
 Sets or returns a synchronizer to the record storage.
 */
@property (nonatomic, readwrite, strong) SKYRecordSynchronizer *synchronizer;

/**
 Returns whether update from remote server is available.
 */
@property (nonatomic, readonly) BOOL hasUpdateAvailable;

- (instancetype)initWithBackingStore:(id<SKYRecordStorageBackingStore>)backingStore;

#pragma mark - Changing all records

/**
 Manually trigger an update to be performed on the receiver.

 Update are performed asynchronously. If there are pending changes, the record storage
 cannot be updated. This method returns <NO> when the receiver cannot perform update.
 */
- (void)performUpdateWithCompletionHandler:(void (^)(BOOL finished,
                                                     NSError *error))completionHandler;

#pragma mark - Saving and removing

/**
 Save specified record.

 If the record is also modified on the remote, you can specify
 an automatic conflict resolution method. If not specified, the
 default method is SKYRecordStorageResolveByReplacing.

 The completion handler is called when the change is synchronized to remote.
 */
- (void)saveRecord:(SKYRecord *)record;
- (void)saveRecord:(SKYRecord *)record
         whenConflict:(SKYRecordResolveMethod)resolution
    completionHandler:(id)handler;
- (void)saveRecords:(NSArray *)records;

/**
 Remove specified record.

 If the record is also modified on the remote, you can specify
 an automatic conflict resolution method. If not specified, the
 default method is SKYRecordStorageResolveByReplacing.

 The completion handler is called when the change is synchronized to remote.
 */
- (void)deleteRecord:(SKYRecord *)record;
- (void)deleteRecord:(SKYRecord *)record
         whenConflict:(SKYRecordResolveMethod)resolution
    completionHandler:(id)handler;
- (void)deleteRecords:(NSArray *)records;

#pragma mark - Fetching and querying multiple records

/**
 Returns a record from record storage.
 */
- (SKYRecord *)recordWithRecordID:(SKYRecordID *)recordID;

/**
 Returns an array of <SKYRecord> with the specified type.
 */
- (NSArray *)recordsWithType:(NSString *)recordType;

/**
 Returns an array of <SKYRecord> with the specified type, filtered
 using the specified predicate.
 */
- (NSArray *)recordsWithType:(NSString *)recordType
                   predicate:(NSPredicate *)predicate
             sortDescriptors:(NSArray *)sortDescriptors;

/**
 Enumerate SKYRecords in the local storage.
 */
- (void)enumerateRecordsWithType:(NSString *)recordType
                       predicate:(NSPredicate *)predicate
                 sortDescriptors:(NSArray *)sortDescriptors
                      usingBlock:(void (^)(SKYRecord *record, BOOL *stop))block;

#pragma mark - Managing Record changes

/**
 Returns whether there exists changes in this storage
 that cannot be synchronized with
 remote and that the change failed due to a permanent error. A
 permanent error
 refers to an error that is likely to reoccur if the change is performed
 again without modification.

 The application should use this property to detect if there
 are failed changes in this storage. Failed changes should
 be acknowledged or resolved.

 @returns YES if there exists failed changes
 */
@property (nonatomic, assign) BOOL hasFailedChanges;

/**
 Reutrns whether there exists pending changes in this storage.
 */
@property (nonatomic, assign) BOOL hasPendingChanges;

/**
 Returns an array of pending record changes.

 Changes are pending when they have not been sent to server for persistence.
 */
- (NSArray *)pendingChanges;

/**
 Returns an array of failed record changes.

 Changes are failed when persistence result in error from server.
 */
- (NSArray *)failedChanges;

- (SKYRecordChange *)changeWithRecord:(SKYRecord *)record;

/*
 The record state of the given record.
 */
- (SKYRecordState)recordStateWithRecord:(SKYRecord *)record;

/**
 Dismisses a record change. Dismissing a change prevents such change
 from being submitted to the remote server.

 Specifying a change that is currently processed by the remote server
 will result in an error.
 */
- (BOOL)dismissChange:(SKYRecordChange *)item error:(NSError **)error;

/**
 Returns a dictionary of modified attributes that will be saved to
 remote server.

 For each entry in the dictionary, the key is the key of the attribute
 that is changed with an array containing both the old and new value of
 the attribute. The object at index 0 correspond to the old value while
 the object at index 1 correspond to the new value.
 */
- (NSDictionary *)attributesToSaveWithRecord:(SKYRecord *)record;

/*
 Handle failed changes.

 <SKYRecordStorage> will call the specified block for each failed record.
 */
- (void)dismissFailedChangesWithBlock:(BOOL (^)(SKYRecordChange *item, SKYRecord *record))block;

#pragma mark - Applying updates

/**
 Notifies the storage that it will begin receiving record updates.
 */
- (void)beginUpdating;
- (void)beginUpdatingForChanges:(BOOL)forChanges;

/**
 Notifies the storage that it has received all record updates.

 Call this method when the you have finished sending remote record updates to the storage. The
 storage uses this opportunity to commit updates to backing store and fires notification that
 the storage is updated.
 */
- (void)finishUpdating;

/**
 Replace all existing records in the backing store with a new array of records.
 */
- (void)updateByReplacingWithRecords:(NSArray *)records;

/**
 Apply a pending change to the backing store.
 */
- (void)updateByApplyingChange:(SKYRecordChange *)change
                recordOnRemote:(SKYRecord *)remoteRecord
                         error:(NSError *)error;

@end
