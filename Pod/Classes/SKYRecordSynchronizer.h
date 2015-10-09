//
//  SKYRecordSynchronizer.h
//  Pods
//
//  Created by atwork on 12/5/15.
//
//

#import <Foundation/Foundation.h>

@class SKYContainer;
@class SKYDatabase;
@class SKYQuery;
@class SKYRecordSynchronizer;
@class SKYRecordStorage;
@class SKYRecordChange;
@class SKYNotification;

/**
 This class handles the network operations required to sync a record storage with remote server.
 */
@interface SKYRecordSynchronizer : NSObject

/**
 The <SKYContaniner> that this this synchronzier synchronizes with.
 */
@property (nonatomic, readonly, strong) SKYContainer *container;

/**
 The <SKYDatabase> that this this synchronzier synchronizes with.
 */
@property (nonatomic, readonly, strong) SKYDatabase *database;

/**
 The <SKYQuery> that this this synchronzier synchronizes with.
 
 Returns <nil> when the synchronizer synchronizes with the entire database.
 */
@property (nonatomic, readonly, strong) SKYQuery *query;

/**
 Instantiate an instance of record synchronizer.
 */
- (instancetype)initWithContainer:(SKYContainer *)container
                         database:(SKYDatabase *)database
                            query:(SKYQuery *)query;


/**
 Notifies the synchronizer that update is available to the specified record storage.
 */
- (void)setUpdateAvailableWithRecordStorage:(SKYRecordStorage *)storage
                               notification:(SKYNotification *)note;

/**
 Instantiate network operations that causes the specified record storage to be updated.
 */
- (void)recordStorageFetchUpdates:(SKYRecordStorage *)storage completionHandler:(void(^)(BOOL finished, NSError *error))completionHandler;

/**
 Instantiate network operations that causes the specified changes to be saved.
 */
- (void)recordStorage:(SKYRecordStorage *)storage saveChanges:(NSArray *)changes completionHandler:(void(^)(BOOL finished, NSError *error))completionHandler;

- (BOOL)isProcessingChange:(SKYRecordChange *)change storage:(SKYRecordStorage *)storage;

@end
