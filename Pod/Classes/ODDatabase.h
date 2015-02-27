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
@class ODRecordZoneID;
@class ODSubscription;

typedef void(^ODRecordSaveCompletion)(ODRecord *record, NSError *error);

@interface ODDatabase : NSObject

@property (nonatomic, readonly) NSString *databaseID;

- (instancetype)init NS_UNAVAILABLE;

- (void)addOperation:(ODDatabaseOperation *)operation;
- (void)executeOperation:(ODDatabaseOperation *)operation;
- (void)commit;

- (void)performQuery:(ODQuery *)query
        inZoneWithID:(ODRecordZoneID *)zoneID
   completionHandler:(void (^)(NSArray *results,
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
 Saves a single record to Ourd.
 
 Use this method to save a single record to Ourd by specifying a <ODReordID>. The save will be performed asynchronously and
 <completionHandler> will be called when the operation completes.
 
 New record will be created in the database while existing record will be modified.
 
 This is a convenient method for <ODModifyRecordsOperation>, which supports saving multiple records by specifying multiple <ODRecordID>s.
 */
- (void)saveRecord:(ODRecord *)record completion:(ODRecordSaveCompletion)completion;
- (void)deleteRecordWithID:(ODRecordID *)recordID
                 completionHandler:(void (^)(ODRecordID *recordID,
                                             NSError *error))completionHandler;

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
