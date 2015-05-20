//
//  ODRecordStorageBackingStore.h
//  Pods
//
//  Created by atwork on 6/5/15.
//
//

#import <Foundation/Foundation.h>
#import "ODRecordChange.h"

@class ODRecord;
@class ODRecordID;

@protocol ODRecordStorageBackingStore <NSObject>

/**
 Writes data to persistent storage if the backing store supports it.
 */
- (void)synchronize;

#pragma mark - Save and delete

/**
 Save a record in the backing store permanently.
 
 When saving a record using this method, any locally made changes of the same record
 are overwritten.
 */
- (void)saveRecord:(ODRecord *)record;

/**
 Save a record in the backing store locally.
 
 A local record is saved alongside a permanently record (if any) such that a record
 can be reverted to the permanent state later. Fetches and queries will now return the locally
 saved record.
 */
- (void)saveRecordLocally:(ODRecord *)record;

/**
 Delete a record in the backing store permanently.

 When deleting a record using this method, any locally made changes of the same record
 are overwritten.
 */
- (void)deleteRecord:(ODRecord *)record;

/**
 Delete a record in the backing store permanently by record ID.
 */
- (void)deleteRecordWithRecordID:(ODRecordID *)recordID;

/**
 Delete a record in the backing store locally.
 
 The local record is deleted but the permanently record (if any) is not affected.
 Fetches and queries will not return the record that is now considered deleted.
 */
- (void)deleteRecordLocally:(ODRecord *)record;

/**
 Delete a record in the backing store locally by record ID.
 */
- (void)deleteRecordLocallyWithRecordID:(ODRecordID *)recordID;

/**
 Revert a record from its local copy to its permanent copy.
 */
- (void)revertRecordLocallyWithRecordID:(ODRecordID *)recordID;

#pragma mark - Fetch and query

/**
 Fetches a record from backing store.
 
 If both a permanent copy and a local copy exist for the same record, the local copy
 will be returned. If the record is deleted locally, this will return nil.
 */
- (ODRecord *)fetchRecordWithRecordID:(ODRecordID *)recordID;

/**
 Returns whether a record from backing store exists.

 If the record is deleted locally, this will return NO.
 */
- (BOOL)existsRecordWithRecordID:(ODRecordID *)recordID;

/**
 Returns record ID of all records with the specified type.
 */
- (NSArray *)recordIDsWithRecordType:(NSString *)recordType;

/**
 Enumerate all records in the backing store regardless of record
 type.
 */
- (void)enumerateRecordsWithBlock:(void (^)(ODRecord *record, BOOL *stop))block;

/**
 Enumerate records in the backing store with the specified type.
 
 You can use this method to enumerate records satisfying a predicate and sorted in an order.
 */
- (void)enumerateRecordsWithType:(NSString *)recordType
                       predicate:(NSPredicate *)predicate
                 sortDescriptors:(NSArray *)sortDescriptors
                      usingBlock:(void (^)(ODRecord *record, BOOL *stop))block;

#pragma mark - Change management

/**
 Append a change to the backing store.
 */
- (void)appendChange:(ODRecordChange *)change;

/**
 Append a change to the backing store.
 
 This method will also set the state to the specified state before appending.
 */
- (void)appendChange:(ODRecordChange *)change state:(ODRecordChangeState)state;

/**
 Remove a change from the backing store.
 
 This will not revert any locally changes. Locally saved changes should be
 reverted separately.
 */
- (void)removeChange:(ODRecordChange *)change;

/**
 Set the current state of the change.
 */
- (void)setState:(ODRecordChangeState)state ofChange:(ODRecordChange *)change;

/**
 Set a change to be finished and specify an NSError that has occurred.
 
 If no error has occurred, it is recommend that -setState:ofChange: be called
 instead.
 */
- (void)setFinishedStateWithError:(NSError *)error ofChange:(ODRecordChange *)change;

/**
 Returns a change related with a record by a record ID.
 */
- (ODRecordChange *)changeWithRecordID:(ODRecordID *)recordID;

/**
 Returns an array of pending changes.
 */
- (NSArray *)pendingChanges;

/**
 Returns an array of failed changes.
 */
- (NSArray *)failedChanges;

- (NSArray *)recordIDsPendingSave;
- (NSArray *)recordIDsPendingDelete;

@end
