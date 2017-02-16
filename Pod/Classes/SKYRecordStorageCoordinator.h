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

@class SKYRecordStorage;
@class SKYDatabase;
@class SKYQuery;
@class SKYContainer;
@class SKYNotification;

extern NSString *const SKYRecordStorageCoordinatorBackingStoreKey;
extern NSString *const SKYRecordStorageCoordinatorMemoryStore;
extern NSString *const SKYRecordStorageCoordinatorFileBackedMemoryStore;
extern NSString *const SKYRecordStorageCoordinatorSqliteStore;
extern NSString *const SKYRecordStorageCoordinatorFilePath;

/**
 The <SKYRecordStorageCoordinator> is responsible for keeping
 references to all <SKYRecordStorage> currently registered.
 It allows retrieving <SKYRecordStorage> across application restart
 so that <SKYRecordStorage> is associated with the same persistent
 storage on device.
 */
@interface SKYRecordStorageCoordinator : NSObject

@property (nonatomic, readonly) SKYContainer *container;

/**
 Returns an array of registered <SKYRecordStorage>.
 */
@property (nonatomic, readonly) NSArray *registeredRecordStorages;

/**
 Sets or returns whether registered <SKYRecordStorage> are auto-purged on user login or logout.
 */
@property (nonatomic, readwrite, getter=isPurgeStoragesOnCurrentUserChanges)
    BOOL purgeStoragesOnCurrentUserChanges;

/**
 Returns the singleton instance of <SKYRecordStorageCoordinator>.
 */
+ (instancetype)defaultCoordinator;

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
- (SKYRecordStorage *)recordStorageWithDatabase:(SKYDatabase *)database
                                          query:(SKYQuery *)query
                                        options:(NSDictionary *)options __deprecated;
- (SKYRecordStorage *)recordStorageWithDatabase:(SKYDatabase *)database
                                          query:(SKYQuery *)query
                                        options:(NSDictionary *)options
                                          error:(NSError **)error;
- (SKYRecordStorage *)recordStorageWithDatabase:(SKYDatabase *)database
                                        options:(NSDictionary *)options __deprecated;
- (SKYRecordStorage *)recordStorageWithDatabase:(SKYDatabase *)database
                                        options:(NSDictionary *)options
                                          error:(NSError **)error;
- (SKYRecordStorage *)recordStorageForPrivateDatabase;

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
