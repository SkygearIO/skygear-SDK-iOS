//
//  SKYRecordStorageBackingStore.h
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

#import "SKYRecordChange.h"
#import <Foundation/Foundation.h>

@class SKYRecord;
@class SKYRecordID;

@protocol SKYRecordStorageBackingStore <NSObject>

/**
 Delete data associated with this backing store.
 */
- (BOOL)purgeWithError:(NSError **)error;

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
- (void)saveRecord:(SKYRecord *)record;

/**
 Save a record in the backing store locally.

 A local record is saved alongside a permanently record (if any) such that a record
 can be reverted to the permanent state later. Fetches and queries will now return the locally
 saved record.
 */
- (void)saveRecordLocally:(SKYRecord *)record;

/**
 Delete a record in the backing store permanently.

 When deleting a record using this method, any locally made changes of the same record
 are overwritten.
 */
- (void)deleteRecord:(SKYRecord *)record;

/**
 Delete a record in the backing store permanently by record ID.
 */
- (void)deleteRecordWithRecordID:(SKYRecordID *)recordID;

/**
 Delete a record in the backing store locally.

 The local record is deleted but the permanently record (if any) is not affected.
 Fetches and queries will not return the record that is now considered deleted.
 */
- (void)deleteRecordLocally:(SKYRecord *)record;

/**
 Delete a record in the backing store locally by record ID.
 */
- (void)deleteRecordLocallyWithRecordID:(SKYRecordID *)recordID;

/**
 Revert a record from its local copy to its permanent copy.
 */
- (void)revertRecordLocallyWithRecordID:(SKYRecordID *)recordID;

#pragma mark - Fetch and query

/**
 Fetches a record from backing store.

 If both a permanent copy and a local copy exist for the same record, the local copy
 will be returned. If the record is deleted locally, this will return nil.
 */
- (SKYRecord *)fetchRecordWithRecordID:(SKYRecordID *)recordID;

/**
 Returns whether a record from backing store exists.

 If the record is deleted locally, this will return NO.
 */
- (BOOL)existsRecordWithRecordID:(SKYRecordID *)recordID;

/**
 Returns record ID of all records with the specified type.
 */
- (NSArray *)recordIDsWithRecordType:(NSString *)recordType;

/**
 Enumerate all records in the backing store regardless of record
 type.
 */
- (void)enumerateRecordsWithBlock:(void (^)(SKYRecord *record, BOOL *stop))block;

/**
 Enumerate records in the backing store with the specified type.

 You can use this method to enumerate records satisfying a predicate and sorted in an order.
 */
- (void)enumerateRecordsWithType:(NSString *)recordType
                       predicate:(NSPredicate *)predicate
                 sortDescriptors:(NSArray *)sortDescriptors
                      usingBlock:(void (^)(SKYRecord *record, BOOL *stop))block;

#pragma mark - Change management

/**
 Append a change to the backing store.
 */
- (void)appendChange:(SKYRecordChange *)change;

/**
 Remove a change from the backing store.

 This will not revert any locally changes. Locally saved changes should be
 reverted separately.
 */
- (void)removeChange:(SKYRecordChange *)change;

/**
 Set a change to be finished and optionally specify an NSError that has occurred.
  */
- (void)setFinishedWithError:(NSError *)error change:(SKYRecordChange *)change;

/**
 Returns a change related with a record by a record ID.
 */
- (SKYRecordChange *)changeWithRecordID:(SKYRecordID *)recordID;

/**
 Returns the number of pending changes.
 */
- (NSUInteger)pendingChangesCount;

/**
 Returns an array of pending changes.
 */
- (NSArray *)pendingChanges;

/**
 Returns an array of failed changes.
 */
- (NSArray *)failedChanges;

@end
