//
//  SKYRecordStorageCoordinator.h
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

@class SKYRecordStorage;
@class SKYDatabase;
@class SKYQuery;
@class SKYContainer;
@class SKYNotification;

/// Undocumented
extern NSString *const SKYRecordStorageCoordinatorBackingStoreKey;
/// Undocumented
extern NSString *const SKYRecordStorageCoordinatorMemoryStore;
/// Undocumented
extern NSString *const SKYRecordStorageCoordinatorFileBackedMemoryStore;
/// Undocumented
extern NSString *const SKYRecordStorageCoordinatorSqliteStore;
/// Undocumented
extern NSString *const SKYRecordStorageCoordinatorFilePath;

/**
 The <SKYRecordStorageCoordinator> is responsible for keeping
 references to all <SKYRecordStorage> currently registered.
 It allows retrieving <SKYRecordStorage> across application restart
 so that <SKYRecordStorage> is associated with the same persistent
 storage on device.
 */
@interface SKYRecordStorageCoordinator : NSObject

/// Undocumented
@property (nonatomic, readonly) SKYContainer *container;

/**
 Returns an array of registered <SKYRecordStorage>.
 */
@property (nonatomic, readonly) NSArray *registeredRecordStorages;

/**
 Sets or returns whether registered <SKYRecordStorage> are auto-purged on user login or logout.
 */
@property (nonatomic, readwrite, getter=isPurgeStoragesOnCurrentUserChanges) BOOL purgeStoragesOnCurrentUserChanges;

/**
 Returns the singleton instance of <SKYRecordStorageCoordinator>.
 */
+ (instancetype)defaultCoordinator;

/// Undocumented
- (instancetype)initWithContainer:(SKYContainer *)container NS_DESIGNATED_INITIALIZER;

/**
 Returns an instance of SKYRecordStorage that is set up to be synchronized
 with the specified scope.

 If the instance of SKYRecordStorage has been created previously with
 <SKYRecord> persisted in the local storage, the same set of <SKYRecord>
 will be available to the returned <SKYRecordStorage>.

 The coordinator keeps references to all <SKYRecordStorage> and
 all of them will synchronize with the remote server.
 */
- (SKYRecordStorage *_Nullable)recordStorageWithDatabase:(SKYDatabase *)database
                                                   query:(SKYQuery *_Nullable)query
                                                 options:(NSDictionary *_Nullable)options __deprecated;
/// Undocumented
- (SKYRecordStorage *_Nullable)recordStorageWithDatabase:(SKYDatabase *)database
                                                   query:(SKYQuery *_Nullable)query
                                                 options:(NSDictionary *_Nullable)options
                                                   error:(NSError **_Nullable)error;
/// Undocumented
- (SKYRecordStorage *_Nullable)recordStorageWithDatabase:(SKYDatabase *)database
                                                 options:(NSDictionary *_Nullable)options __deprecated;
/// Undocumented
- (SKYRecordStorage *_Nullable)recordStorageWithDatabase:(SKYDatabase *)database
                                                 options:(NSDictionary *_Nullable)options
                                                   error:(NSError **_Nullable)error;
/// Undocumented
- (SKYRecordStorage *_Nullable)recordStorageForPrivateDatabase;

/**
 Removes an <SKYRecordStorage> from an internal registry of local storage.

 When this method is called, the coordinator will not propagate remote
 record updates to the specified <SKYRecordStorage>
 */
- (void)forgetRecordStorage:(SKYRecordStorage *)recordStorage;

/**
 Removes all <SKYRecordStorage> from an internal registry of local storage.
 */
- (void)forgetAllRecordStorages;

/**
 Handles remote notification payload so that all registered <SKYRecordStorage>
 have a chance to updates its local storage.

 You are expecte to call this method when in your implementation of
 -[UIApplicationDelegate application:didReceiveRemoteNotification:].

 If this method returns YES, it means the remote notification
 has been handled by <SKYRecordStorageCoordinator>.
 */
- (BOOL)handleUpdateWithRemoteNotification:(SKYNotification *)note;

@end

NS_ASSUME_NONNULL_END
