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

- (instancetype)initWithBackingStore:(id<ODRecordStorageBackingStore>)backingStore;

/**
 Handles a remote notification dictionary.
 
 When a remote notification is received, the application should call
 this method so that the <ODRecordStorage> can fetch updates from remote.
 */
- (BOOL)handleUpdateWithRemoteNotification:(NSDictionary *)info;

#pragma mark - Saving and removing.

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
 Revert a record to the last synchronized state.
 */
- (void)revertRecord:(ODRecord *)record;

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

@end
