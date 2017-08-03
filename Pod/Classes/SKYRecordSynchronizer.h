//
//  SKYRecordSynchronizer.h
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

NS_ASSUME_NONNULL_BEGIN

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
@property (nonatomic, readonly, strong) SKYQuery *_Nullable query;

/**
 Instantiate an instance of record synchronizer.
 */
- (instancetype)initWithContainer:(SKYContainer *)container
                         database:(SKYDatabase *)database
                            query:(SKYQuery *_Nullable)query;

/**
 Notifies the synchronizer that update is available to the specified record storage.
 */
- (void)setUpdateAvailableWithRecordStorage:(SKYRecordStorage *)storage
                               notification:(SKYNotification *)note;

/**
 Instantiate network operations that causes the specified record storage to be updated.
 */
- (void)recordStorageFetchUpdates:(SKYRecordStorage *)storage
                completionHandler:
                    (void (^_Nullable)(BOOL finished, NSError *_Nullable error))completionHandler;

/**
 Instantiate network operations that causes the specified changes to be saved.
 */
- (void)recordStorage:(SKYRecordStorage *)storage
          saveChanges:(NSArray *)changes
    completionHandler:(void (^_Nullable)(BOOL finished, NSError *_Nullable error))completionHandler;

/// Undocumented
- (BOOL)isProcessingChange:(SKYRecordChange *)change storage:(SKYRecordStorage *)storage;

@end

NS_ASSUME_NONNULL_END
