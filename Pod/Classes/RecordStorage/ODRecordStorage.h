//
//  ODRecordStorage.h
//  Pods
//
//  Created by atwork on 4/5/15.
//
//

#import <Foundation/Foundation.h>

#import "ODRecord.h"
#import "ODRecordChange.h"
#import "ODRecordResultController.h"
#import "ODRecordStorageBackingStore.h"

extern NSString * const ODRecordStorageDidUpdateNotification;
extern NSString * const ODRecordStorageWillSynchronizeChangesNotification;
extern NSString * const ODRecordStorageDidSynchronizeChangesNotification;
extern NSString * const ODRecordStorageUpdateAvailableNotification;
extern NSString * const ODRecordStoragePendingChangesCountKey;
extern NSString * const ODRecordStorageFailedChangesCountKey;
extern NSString * const ODRecordStorageSavedRecordIDsKey;
extern NSString * const ODRecordStorageDeletedRecordIDsKey;

@class ODRecordSynchronizer;

typedef enum : NSInteger {
    /**
     Record is in the same state as the last known state on server.
     */
    ODRecordStateSynchronized,
    
    /**
     Record is changed locally and is yet to be saved on server.
     */
    ODRecordStateNotSynchronized,
    
    /**
     Record is changed locally and is yet to be saved on server.
     */
    ODRecordStateSynchronizing,
    
    /**
     Record is in a state that is in conflict with the state on server.
     */
    ODRecordStateConflicted,
} ODRecordState;


/**
 <ODRecordStorage> provides a local storage for records that is synchronized
 with a subset of records on remote server. Changes made remotely are
 reflected on the local storage and vice versa.
 
 This class is useful for applications in which records are available
 offline, and that user may modify data when device is offline to
 have changes uploaded to remote server when device becomes online again.
 
 User should not instantiate an instance of this class directly. An
 instance of <ODRecordStorage> should be obtained from
 <ODRecordStorageCoordinator>.
 */
@interface ODRecordStorage : NSObject

/**
 Returns whether the <ODRecordStorage> should synchronizes changes
 from remote to local and vice versa.
 
 When this is YES, any pending changes will be performed at an appropriate
 time. When this is set to NO, any changes will be kept in pending state
 until this is set to YES again.
 */
@property (nonatomic, assign) BOOL enabled;

/**
 Returns whether the <ODRecordStorage> is currently updating the backing store.
 
 When the backing store is being updated, calling -beginUpdating is not allowed.
 */
@property (nonatomic, readonly, getter=isUpdating) BOOL updating;

/**
 Returns the backing store object used to initialize the the storage.
 */
@property (nonatomic, readonly, strong) id<ODRecordStorageBackingStore> backingStore;

/**
 Sets or returns a synchronizer to the record storage.
 */
@property (nonatomic, readwrite, strong) ODRecordSynchronizer *synchronizer;

- (instancetype)initWithBackingStore:(id<ODRecordStorageBackingStore>)backingStore;

/**
 Handles a remote notification dictionary.
 
 When a remote notification is received, the application should call
 this method so that the <ODRecordStorage> can fetch updates from remote.
 */
- (BOOL)handleUpdateWithRemoteNotification:(NSDictionary *)info;

#pragma mark - Changing all records

/**
 Manually trigger an update to be performed on the receiver.
 
 Update are performed asynchronously. If there are pending changes, the record storage
 cannot be updated. This method returns <NO> when the receiver cannot perform update.
 */
- (BOOL)performUpdateWithError:(NSError **)error;

#pragma mark - Saving and removing

/**
 Save specified record.
 
 If the record is also modified on the remote, you can specify
 an automatic conflict resolution method. If not specified, the
 default method is ODRecordStorageResolveByReplacing.
 
 The completion handler is called when the change is synchronized to remote.
 */
- (void)saveRecord:(ODRecord *)record;
- (void)saveRecord:(ODRecord *)record whenConflict:(ODRecordResolveMethod)resolution completionHandler:(id)handler;
- (void)saveRecords:(NSArray *)records;

/**
 Remove specified record.
 
 If the record is also modified on the remote, you can specify
 an automatic conflict resolution method. If not specified, the
 default method is ODRecordStorageResolveByReplacing.
 
 The completion handler is called when the change is synchronized to remote.
 */
- (void)deleteRecord:(ODRecord *)record;
- (void)deleteRecord:(ODRecord *)record whenConflict:(ODRecordResolveMethod)resolution completionHandler:(id)handler;
- (void)deleteRecords:(NSArray *)records;

#pragma mark - Fetching and querying multiple records

/**
 Returns a record from record storage.
 */
- (ODRecord *)recordWithRecordID:(ODRecordID *)recordID;

/**
 Returns an array of <ODRecord> with the specified type.
 */
- (NSArray *)recordsWithType:(NSString *)recordType;

/**
 Returns an array of <ODRecord> with the specified type, filtered
 using the specified predicate.
 */
- (NSArray *)recordsWithType:(NSString *)recordType predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors;

/**
 Enumerate ODRecords in the local storage.
 */
- (void)enumerateRecordsWithType:(NSString *)recordType predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors usingBlock:(void (^)(ODRecord *record, BOOL *stop))block;

/**
 Returns ODRecordResultController.
 */
- (ODRecordResultController *)recordResultControllerWithType:(NSString *)recordType predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors;

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

- (ODRecordChange *)changeWithRecord:(ODRecord *)record;

/*
 The record state of the given record.
 */
- (ODRecordState)recordStateWithRecord:(ODRecord *)record;

/**
 Dismisses a record change. Dismissing a change prevents such change
 from being submitted to the remote server.
 
 Specifying a change that is currently processed by the remote server
 will result in an error.
 */
- (BOOL)dismissChange:(ODRecordChange *)item error:(NSError **)error;

/**
 Returns a dictionary of modified attributes that will be saved to
 remote server.
 
 For each entry in the dictionary, the key is the key of the attribute
 that is changed with an array containing both the old and new value of
 the attribute. The object at index 0 correspond to the old value while
 the object at index 1 correspond to the new value.
 */
- (NSDictionary *)attributesToSaveWithRecord:(ODRecord *)record;


/*
 Handle failed changes.
 
 <ODRecordStorage> will call the specified block for each failed record.
 */
- (void)dismissFailedChangesWithBlock:(BOOL (^)(ODRecordChange *item, ODRecord *record))block;

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
- (void)updateByApplyingChange:(ODRecordChange *)change
                     recordOnRemote:(ODRecord *)remoteRecord
                              error:(NSError *)error;

@end
