//
//  SKYDatabase.h
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

#import "SKYAsset.h"
#import "SKYRecord.h"
#import "SKYRecordResult.h"

NS_ASSUME_NONNULL_BEGIN

@class SKYDatabaseOperation;
@class SKYQuery;
@class SKYSubscription;
@class SKYContainer;

/// Undocumented
@interface SKYDatabase : NSObject

/// Undocumented
@property (nonatomic, strong, readonly) NSString *databaseID;
/// Undocumented
@property (nonatomic, strong, readonly) SKYContainer *container;

/// Undocumented
- (instancetype)init NS_UNAVAILABLE;

/// Undocumented
- (void)addOperation:(SKYDatabaseOperation *)operation;
/// Undocumented
- (void)executeOperation:(SKYDatabaseOperation *)operation;
/// Undocumented
- (void)commit;

/**
 Perform a query on the server.

 When result is available, the completion block will be called.

 @param completion block to be called when query result is available
 */
- (void)performQuery:(SKYQuery *)query
          completion:(void (^_Nullable)(NSArray<SKYRecord *> *_Nullable results,
                                        NSError *_Nullable error))completion
    /* clang-format off */ NS_SWIFT_NAME(performQuery(_:completion:)); /* clang-format on */

/**
 Perform a query on the server.

 If a cached result of the same query is available, the completion block will be called
 with the cached result first. When result is available from the server, the completion
 block will be called with the server result.

 @param completion block to be called when query result is available
 */
- (void)performCachedQuery:(SKYQuery *)query
                completion:(void (^_Nullable)(NSArray<SKYRecord *> *_Nullable results, BOOL pending,
                                              NSError *_Nullable error))completion
    /* clang-format off */ NS_SWIFT_NAME(performCachedQuery(_:completion:)); /* clang-format on */

/**
 Fetches a single record from Skygear.

 Use this method to fetch a single record from Skygear by specifying record type an record ID. The
 fetch will be performed asynchronously and <completion> will be called when the operation
 completes.

 @param recordType the record to fetch
 @param recordID the record identifier to fetch
 @param completion the block to be called when operation completes.
 */
- (void)fetchRecordWithType:(NSString *)recordType
                   recordID:(NSString *)recordID
                 completion:(void (^_Nullable)(SKYRecord *_Nullable record,
                                               NSError *_Nullable error))completion
    /* clang-format off */ NS_SWIFT_NAME(fetchRecord(type:recordID:completion:)); /* clang-format on */

/**
 Fetches multiple records from Skygear.

 Use this method to fetch multiple records from Skygear by specifying an array of <SKYRecordID>s.
 The fetch will be performed asynchronously and <completion> will be called when the
 operation completes.

 @param recordType the record to fetch
 @param recordIDs the record identifiers to fetch
 @param completion the block to be called when operation completes
 */
- (void)fetchRecordsWithType:(NSString *)recordType
                   recordIDs:(NSArray<NSString *> *)recordIDs
                  completion:
                      (void (^_Nullable)(NSArray<SKYRecordResult<SKYRecord *> *> *_Nullable results,
                                         NSError *_Nullable operationError))completion
    /* clang-format off */ NS_REFINED_FOR_SWIFT; /* clang-format on */

/**
 Saves a single record to Skygear.

 Use this method to save a single record to Skygear by specifying a <SKYReord>. The save will be
 performed asynchronously and
 <completion> will be called when the operation completes.

 New record will be created in the database while existing record will be modified.

 This is a convenient method for <SKYModifyRecordsOperation>, which supports saving multiple records
 by specifying multiple <SKYRecordID>s.

 @param record the record to save
 @param completion the block to be called when operation completes. The specified block is
 also called when an operation error occurred.
 */
- (void)saveRecord:(SKYRecord *)record
        completion:(void (^_Nullable)(SKYRecord *_Nullable record,
                                      NSError *_Nullable operationError))completion
    /* clang-format off */ NS_SWIFT_NAME(saveRecord(_:completion:)); /* clang-format on */

/**
 Saves multiple records to Skygear.

 Use this method to save multiple record to Skygear by specifying an array of <SKYReord>s. The save
 will be performed asynchronously and
 <completion> will be called when the operation completes.

 New records will be created in the database while existing records will be modified.

 This is a convenient method for <SKYModifyRecordsOperation>.

 @param records the records to save
 @param completion the block to be called when operation completes. The specified block is
 also called when an operation error occurred.
 */
- (void)saveRecords:(NSArray<SKYRecord *> *)records
         completion:(void (^_Nullable)(NSArray *_Nullable savedRecords,
                                       NSError *_Nullable operationError))completion
    /* clang-format off */ NS_SWIFT_NAME(saveRecords(_:completion:)); /* clang-format on */

/**
 Saves multiple records non-atomically to Skygear.

 The behaviour of this method is identical to saveRecords:completion:,
 except that some records will be saved if other records have failed to save.

 @param records the records to save
 @param completion the block to be called when operation completes. The specified block is
 also called when an operation error occurred.
 */
- (void)saveRecordsNonAtomically:(NSArray<SKYRecord *> *)records
                      completion:(void (^_Nullable)(
                                     NSArray<SKYRecordResult<SKYRecord *> *> *_Nullable results,
                                     NSError *_Nullable operationError))completion
    /* clang-format off */ NS_REFINED_FOR_SWIFT; /* clang-format on */

/**
 Deletes a single record from Skygear.

 Use this method to delete a single record from Skygear. The deletion
 will be performed asynchronously and
 <completion> will be called when the operation completes.

 @param recordType the record type to delete
 @param recordID the record identifier to delete
 @param completion the block to be called when operation completes. The specified block is
 also called when an operation error occurred.
 */
- (void)deleteRecordWithType:(NSString *)recordType
                    recordID:(NSString *)recordID
                  completion:(void (^_Nullable)(NSString *_Nullable recordID,
                                                NSError *_Nullable error))completion
    /* clang-format off */ NS_SWIFT_NAME(deleteRecord(type:recordID:completion:)); /* clang-format on */

/**
 Deletes multiple records from Skygear.

 Use this method to delete multiple records from Skygear. The
 deletion will be performed asynchronously and <completionHandler> will be called when the operation
 completes.

 @param recordType the record type to delete
 @param recordIDs the record identifiers to delete
 @param completion the block to be called when operation completes. The specified block is
 also called when an operation error occurred.
 */
- (void)deleteRecordsWithType:(NSString *)recordType
                    recordIDs:(NSArray<NSString *> *)recordIDs
                   completion:(void (^_Nullable)(NSArray<NSString *> *_Nullable deletedRecordIDs,
                                                 NSError *_Nullable error))completion
    /* clang-format off */ NS_SWIFT_NAME(deleteRecords(type:recordIDs:completion:)); /* clang-format on */

/**
 Deletes multiple records non-atomically to Skygear.

 The behaviour of this method is identical to
 deleteRecordsWithType:recordIDs:completion:perRecordErrorHandler:,
 except that it also sets the atomic flag on the operation.

 Since the operation either succeeds or fails as a whole, perRecordErrorHandler is omitted.

 @param recordType the record type to delete
 @param recordIDs the records to save
 @param completion the block to be called when operation completes. The specified block is
 also called when an operation error occurred.
 */
- (void)deleteRecordsNonAtomicallyWithType:(NSString *)recordType
                                 recordIDs:(NSArray<NSString *> *)recordIDs
                                completion:
                                    (void (^_Nullable)(
                                        NSArray<SKYRecordResult<NSString *> *> *_Nullable results,
                                        NSError *_Nullable error))completion
    /* clang-format off */ NS_REFINED_FOR_SWIFT; /* clang-format on */

/**
 Deletes a single record from Skygear.

 Use this method to delete a single record from Skygear. The deletion
 will be performed asynchronously and
 <completion> will be called when the operation completes.

 @param record the record to delete
 @param completion the block to be called when operation completes. The specified block is
 also called when an operation error occurred.
 */
- (void)deleteRecord:(SKYRecord *)record
          completion:
              (void (^_Nullable)(SKYRecord *_Nullable record, NSError *_Nullable error))completion
    /* clang-format off */ NS_SWIFT_NAME(deleteRecord(_:completion:)); /* clang-format on */

/**
 Deletes multiple records from Skygear.

 Use this method to delete multiple records from Skygear. The
 deletion will be performed asynchronously and <completion> will be called when the operation
 completes.

 @param records the records to delete
 @param completion the block to be called when operation completes. The specified block is
 also called when an operation error occurred.
 */
- (void)deleteRecords:(NSArray<SKYRecord *> *)records
           completion:(void (^_Nullable)(NSArray<SKYRecord *> *_Nullable deletedRecords,
                                         NSError *_Nullable error))completion
    /* clang-format off */ NS_SWIFT_NAME(deleteRecords(_:completion:)); /* clang-format on */

/**
 Deletes multiple records non-atomically to Skygear.

 The behaviour of this method is identical to
 deleteRecordsWithType:recordIDs:completion:perRecordErrorHandler:,
 except that it also sets the atomic flag on the operation.

 Since the operation either succeeds or fails as a whole, perRecordErrorHandler is omitted.

 @param records the records to delete
 @param completion the block to be called when operation completes. The specified block is
 also called when an operation error occurred.
 */
- (void)deleteRecordsNonAtomicallyRecords:(NSArray<SKYRecord *> *)records
                               completion:(void (^_Nullable)(NSArray<SKYRecordResult<SKYRecord *> *>
                                                                 *_Nullable deletedRecords,
                                                             NSError *_Nullable error))completion
    /* clang-format off */ NS_REFINED_FOR_SWIFT; /* clang-format on */

/// Undocumented
- (void)fetchAllSubscriptionsWithCompletionHandler:
    (void (^_Nullable)(NSArray *_Nullable subscriptions,
                       NSError *_Nullable error))completionHandler;
/// Undocumented
- (void)fetchSubscriptionWithID:(NSString *)subscriptionID
              completionHandler:(void (^_Nullable)(SKYSubscription *_Nullable subscription,
                                                   NSError *_Nullable error))completionHandler;
/// Undocumented
- (void)saveSubscription:(SKYSubscription *)subscription
       completionHandler:(void (^_Nullable)(SKYSubscription *_Nullable subscription,
                                            NSError *_Nullable error))completionHandler;
/// Undocumented
- (void)deleteSubscriptionWithID:(NSString *)subscriptionID
               completionHandler:(void (^_Nullable)(NSString *_Nullable subscriptionID,
                                                    NSError *_Nullable error))completionHandler;

/// Undocumented
- (void)uploadAsset:(SKYAsset *_Nonnull)asset
    completionHandler:(void (^_Nullable)(SKYAsset *_Nullable, NSError *_Nullable))completionHandler;

@end

@interface SKYDatabase (SKYUser)

/// Undocumented
@property (nonatomic, readonly) NSString *_Nullable currentUserRecordID;

@end

@interface SKYDatabase (SKYNewsfeed)

/// Undocumented
- (void)fetchUserNewsFeed:(NSString *)newsfeedID
        completionHandler:(void (^_Nullable)(SKYRecord *_Nullable results,
                                             NSError *_Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
