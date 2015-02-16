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

- (void)fetchRecordWithID:(ODRecordID *)recordID
        completionHandler:(void (^)(ODRecord *record,
                                    NSError *error))completionHandler;
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
