//
//  SKYDatabase.h
//  SkyKit
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

#import <Foundation/Foundation.h>

#import "SKYUser.h"
#import "SKYRecord.h"

@class SKYDatabaseOperation;
@class SKYQuery;
@class SKYSubscription;
@class SKYContainer;

typedef void (^SKYRecordSaveCompletion)(SKYRecord *record, NSError *error);

@interface SKYDatabase : NSObject

@property (nonatomic, strong) NSString *databaseID;
@property (nonatomic, strong, readonly) SKYContainer *container;

- (instancetype)init NS_UNAVAILABLE;

- (void)addOperation:(SKYDatabaseOperation *)operation;
- (void)executeOperation:(SKYDatabaseOperation *)operation;
- (void)commit;

- (void)performQuery:(SKYQuery *)query
   completionHandler:(void (^)(NSArray *results, NSError *error))completionHandler;
- (void)performCachedQuery:(SKYQuery *)query
         completionHandler:
             (void (^)(NSArray *results, BOOL pending, NSError *error))completionHandler;

/**
 Fetches a single record from Ourd.

 Use this method to fetch a single record from Ourd by specifying a <SKYRecordID>. The fetch will be
 performed asynchronously
 and <completeionHandler> will be called when the operation completes.

 This is a convenient method for <SKYFetchRecordsOperation>, which supports fetching multiple
 records by specifying multiple <SKYRecordID>s.

 @param recordID the record identifier to fetch
 @param completionHandler the block to be called when operation completes.
 */
- (void)fetchRecordWithID:(SKYRecordID *)recordID
        completionHandler:(void (^)(SKYRecord *record, NSError *error))completionHandler;

/**
 Fetches multiple records from Ourd.

 Use this method to fetch multiple records from Ourd by specifying an array of <SKYRecordID>s. The
 fetch will be performed asynchronously
 and <completeionHandler> will be called when the operation completes.

 This is a convenient method for <SKYFetchRecordsOperation>.

 @param recordIDs the record identifiers to fetch
 @param completionHandler the block to be called when operation completes. The specified block is
 also called when an operation error occurred.
 @param errorHandler the block to be called when an error occurred to individual record operation
 */
- (void)fetchRecordsWithIDs:(NSArray *)recordIDs
          completionHandler:(void (^)(NSDictionary *recordsByRecordID,
                                      NSError *operationError))completionHandler
      perRecordErrorHandler:(void (^)(SKYRecordID *recordID, NSError *error))errorHandler;

/**
 Saves a single record to Ourd.

 Use this method to save a single record to Ourd by specifying a <SKYReord>. The save will be
 performed asynchronously and
 <completionHandler> will be called when the operation completes.

 New record will be created in the database while existing record will be modified.

 This is a convenient method for <SKYModifyRecordsOperation>, which supports saving multiple records
 by specifying multiple <SKYRecordID>s.

 @param record the record to save
 @param completionHandler the block to be called when operation completes. The specified block is
 also called when an operation error occurred.
 */
- (void)saveRecord:(SKYRecord *)record completion:(SKYRecordSaveCompletion)completion;

/**
 Saves multiple records to Ourd.

 Use this method to save multiple record to Ourd by specifying an array of <SKYReord>s. The save
 will be performed asynchronously and
 <completionHandler> will be called when the operation completes.

 New records will be created in the database while existing records will be modified.

 This is a convenient method for <SKYModifyRecordsOperation>.

 @param records the records to save
 @param completionHandler the block to be called when operation completes. The specified block is
 also called when an operation error occurred.
 @param errorHandler the block to be called when an error occurred to individual record operation
 */
-
    (void)saveRecords:(NSArray *)records
    completionHandler:(void (^)(NSArray *savedRecords, NSError *operationError))completionHandler
perRecordErrorHandler:(void (^)(SKYRecord *record, NSError *error))errorHandler;

/**
 Saves multiple records atomically to Ourd.

 The behaviour of this method is identical to saveRecords:completionHandler:perRecordErrorHandler:,
 except that it also sets the atomic flag on the operation.

 Since the operation either succeeds or fails as a whole, perRecordErrorHandler is omitted.

 @param records the records to save
 @param completionHandler the block to be called when operation completes. The specified block is
 also called when an operation error occurred.
 */
- (void)saveRecordsAtomically:(NSArray *)records
            completionHandler:
                (void (^)(NSArray *savedRecords, NSError *operationError))completionHandler;

/**
 Deletes a single record from Ourd.

 Use this method to delete a single record from Ourd by specifying a <SKYRecordID>. The deletion
 will be performed asynchronously and
 <completionHandler> will be called when the operation completes.

 This is a convenient method for <SKYDeleteRecordsOperation>, which supports deleting multiple
 records by specifying multiple <SKYRecordID>s.

 @param recordID the record identifier to delete
 @param completionHandler the block to be called when operation completes. The specified block is
 also called when an operation error occurred.
 */
- (void)deleteRecordWithID:(SKYRecordID *)recordID
         completionHandler:(void (^)(SKYRecordID *recordID, NSError *error))completionHandler;

/**
 Deletes multiple records from Ourd.

 Use this method to delete multiple records from Ourd by specifying a <SKYRecordID>s. The deletion
 will be performed asynchronously and
 <completionHandler> will be called when the operation completes.

 This is a convenient method for <SKYDeleteRecordsOperation>.

 @param recordIDs the record identifiers to delete
 @param completionHandler the block to be called when operation completes. The specified block is
 also called when an operation error occurred.
 @param errorHandler the block to be called when an error occurred to individual record operation
 */
- (void)deleteRecordsWithIDs:(NSArray *)recordIDs
           completionHandler:(void (^)(NSArray *deletedRecordIDs, NSError *error))completionHandler
       perRecordErrorHandler:(void (^)(SKYRecordID *recordID, NSError *error))errorHandler;

/**
 Deletes multiple records atomically to Ourd.

 The behaviour of this method is identical to
 deleteRecordsWithIDs:completionHandler:perRecordErrorHandler:,
 except that it also sets the atomic flag on the operation.

 Since the operation either succeeds or fails as a whole, perRecordErrorHandler is omitted.

 @param records the records to save
 @param completionHandler the block to be called when operation completes. The specified block is
 also called when an operation error occurred.
 */
- (void)deleteRecordsWithIDsAtomically:(NSArray *)recordIDs
                     completionHandler:
                         (void (^)(NSArray *deletedRecordIDs, NSError *error))completionHandler;

- (void)fetchAllSubscriptionsWithCompletionHandler:(void (^)(NSArray *subscriptions,
                                                             NSError *error))completionHandler;
- (void)fetchSubscriptionWithID:(NSString *)subscriptionID
              completionHandler:
                  (void (^)(SKYSubscription *subscription, NSError *error))completionHandler;
- (void)saveSubscription:(SKYSubscription *)subscription
       completionHandler:(void (^)(SKYSubscription *subscription, NSError *error))completionHandler;
- (void)deleteSubscriptionWithID:(NSString *)subscriptionID
               completionHandler:
                   (void (^)(NSString *subscriptionID, NSError *error))completionHandler;

@end

@interface SKYDatabase (SKYUser)

@property (nonatomic, readonly) SKYUser *currentUser;

@end

@interface SKYDatabase (SKYNewsfeed)

- (void)fetchUserNewsFeed:(NSString *)newsfeedID
        completionHandler:(void (^)(SKYRecord *results, NSError *error))completionHandler;

@end
