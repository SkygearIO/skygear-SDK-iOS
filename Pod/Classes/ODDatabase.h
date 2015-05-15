//
//  ODDatabase.h
//  askq
//
//  Created by Kenji Pa on 19/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ODUser.h"
#import "ODRecord.h"

@class ODDatabaseOperation;
@class ODQuery;
@class ODSubscription;
@class ODContainer;

typedef void(^ODRecordSaveCompletion)(ODRecord *record, NSError *error);

@interface ODDatabase : NSObject

@property (nonatomic, strong) NSString *databaseID;
@property (nonatomic, strong, readonly) ODContainer *container;

- (instancetype)init NS_UNAVAILABLE;

- (void)addOperation:(ODDatabaseOperation *)operation;
- (void)executeOperation:(ODDatabaseOperation *)operation;
- (void)commit;

- (void)performQuery:(ODQuery *)query
   completionHandler:(void (^)(NSArray *results,
                               NSError *error))completionHandler;
- (void)performCachedQuery:(ODQuery *)query
         completionHandler:(void (^)(NSArray *results,
                                     BOOL pending,
                                     NSError *error))completionHandler;

/**
 Fetches a single record from Ourd.
 
 Use this method to fetch a single record from Ourd by specifying a <ODRecordID>. The fetch will be performed asynchronously
 and <completeionHandler> will be called when the operation completes.
 
 This is a convenient method for <ODFetchRecordsOperation>, which supports fetching multiple records by specifying multiple <ODRecordID>s.
 
 @param recordID the record identifier to fetch
 @param completionHandler the block to be called when operation completes.
 */
- (void)fetchRecordWithID:(ODRecordID *)recordID
        completionHandler:(void (^)(ODRecord *record,
                                    NSError *error))completionHandler;

/**
 Fetches multiple records from Ourd.
 
 Use this method to fetch multiple records from Ourd by specifying an array of <ODRecordID>s. The fetch will be performed asynchronously
 and <completeionHandler> will be called when the operation completes.
 
 This is a convenient method for <ODFetchRecordsOperation>.
 
 @param recordIDs the record identifiers to fetch
 @param completionHandler the block to be called when operation completes. The specified block is also called when an operation error occurred.
 @param errorHandler the block to be called when an error occurred to individual record operation
 */
- (void)fetchRecordsWithIDs:(NSArray *)recordIDs
          completionHandler:(void (^)(NSDictionary *recordsByRecordID,
                                      NSError *operationError))completionHandler
      perRecordErrorHandler:(void (^)(ODRecordID *recordID, NSError *error))errorHandler;

/**
 Saves a single record to Ourd.
 
 Use this method to save a single record to Ourd by specifying a <ODReord>. The save will be performed asynchronously and
 <completionHandler> will be called when the operation completes.
 
 New record will be created in the database while existing record will be modified.
 
 This is a convenient method for <ODModifyRecordsOperation>, which supports saving multiple records by specifying multiple <ODRecordID>s.

 @param record the record to save
 @param completionHandler the block to be called when operation completes. The specified block is also called when an operation error occurred.
 */
- (void)saveRecord:(ODRecord *)record completion:(ODRecordSaveCompletion)completion;

/**
 Saves multiple record to Ourd.
 
 Use this method to save multiple record to Ourd by specifying an array of <ODReord>s. The save will be performed asynchronously and
 <completionHandler> will be called when the operation completes.
 
 New records will be created in the database while existing records will be modified.
 
 This is a convenient method for <ODModifyRecordsOperation>.

 @param records the records to save
 @param completionHandler the block to be called when operation completes. The specified block is also called when an operation error occurred.
 @param errorHandler the block to be called when an error occurred to individual record operation
 */
- (void)saveRecords:(NSArray *)records
  completionHandler:(void (^)(NSArray *savedRecords,
                              NSError *operationError))completionHandler
perRecordErrorHandler:(void (^)(ODRecord *record, NSError *error))errorHandler;


/**
 Deletes a single record from Ourd.
 
 Use this method to delete a single record from Ourd by specifying a <ODRecordID>. The deletion will be performed asynchronously and
 <completionHandler> will be called when the operation completes.
 
 This is a convenient method for <ODDeleteRecordsOperation>, which supports deleting multiple records by specifying multiple <ODRecordID>s.

 @param recordID the record identifier to delete
 @param completionHandler the block to be called when operation completes. The specified block is also called when an operation error occurred.
 */
- (void)deleteRecordWithID:(ODRecordID *)recordID
                 completionHandler:(void (^)(ODRecordID *recordID,
                                             NSError *error))completionHandler;

/**
 Deletes multiple record from Ourd.
 
 Use this method to delete multiple records from Ourd by specifying a <ODRecordID>s. The deletion will be performed asynchronously and
 <completionHandler> will be called when the operation completes.
 
 This is a convenient method for <ODDeleteRecordsOperation>.
 
 @param recordIDs the record identifiers to delete
 @param completionHandler the block to be called when operation completes. The specified block is also called when an operation error occurred.
 @param errorHandler the block to be called when an error occurred to individual record operation
 */
- (void)deleteRecordsWithIDs:(NSArray *)recordIDs
           completionHandler:(void (^)(NSArray *deletedRecordIDs,
                                       NSError *error))completionHandler
       perRecordErrorHandler:(void (^)(ODRecordID *recordID, NSError *error))errorHandler;

- (void)fetchAllSubscriptionsWithCompletionHandler:(void (^)(NSArray *subscriptions,
                                                             NSError *error))completionHandler;
- (void)fetchSubscriptionWithID:(NSString *)subscriptionID
              completionHandler:(void (^)(ODSubscription *subscription,
                                          NSError *error))completionHandler;
- (void)saveSubscription:(ODSubscription *)subscription
       completionHandler:(void (^)(ODSubscription *subscription,
                                   NSError *error))completionHandler;
- (void)deleteSubscriptionWithID:(NSString *)subscriptionID
               completionHandler:(void (^)(NSString *subscriptionID,
                                           NSError *error))completionHandler;

@end

@interface ODDatabase (ODUser)

@property (nonatomic, readonly) ODUser *currentUser;

@end

@interface ODDatabase (ODNewsfeed)

- (void)fetchUserNewsFeed:(NSString *)newsfeedID completionHandler:(void (^)(ODRecord *results, NSError *error))completionHandler;

@end
