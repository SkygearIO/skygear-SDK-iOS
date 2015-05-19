//
//  ODRecordStorageCoordinator.h
//  Pods
//
//  Created by atwork on 7/5/15.
//
//

#import <Foundation/Foundation.h>

@class ODRecordStorage;
@class ODDatabase;
@class ODQuery;
@class ODContainer;

extern NSString * const ODRecordStorageCoordinatorBackingStoreKey;
extern NSString * const ODRecordStorageCoordinatorMemoryStore;
extern NSString * const ODRecordStorageCoordinatorFileBackedMemoryStore;
extern NSString * const ODRecordStorageCoordinatorFilePath;

/**
 The <ODRecordStorageCoordinator> is responsible for keeping
 references to all <ODRecordStorage> currently registered.
 It allows retrieving <ODRecordStorage> across application restart
 so that <ODRecordStorage> is associated with the same persistent
 storage on device.
 */
@interface ODRecordStorageCoordinator : NSObject

@property (nonatomic, readonly) ODContainer *container;


/**
 Returns an array of registered <ODRecordStorage>.
 */
@property (nonatomic, readonly) NSArray *recordStorages;

/**
 Returns the singleton instance of <ODRecordStorageCoordinator>.
 */
+ (instancetype)defaultCoordinator;

- (instancetype)initWithContainer:(ODContainer *)container NS_DESIGNATED_INITIALIZER;

/**
 Returns an instance of ODRecordStorage that is set up to be synchronized
 with the specified scope.
 
 If the instance of ODRecordStorage has been created previously with
 <ODRecord> persisted in the local storage, the same set of <ODRecord>
 will be available to the returned <ODRecordStorage>.
 
 The coordinator keeps references to all <ODRecordStorage> and
 all of them will synchronize with the remote server.
 */
- (ODRecordStorage *)recordStorageWithDatabase:(ODDatabase *)database query:(ODQuery *)query options:(NSDictionary *)options;
- (ODRecordStorage *)recordStorageWithDatabase:(ODDatabase *)database options:(NSDictionary *)options;
- (ODRecordStorage *)recordStorageForPrivateDatabase;

/**
 Removes an <ODRecordStorage> from an internal registry of local storage.
 
 When this method is called, the coordinator will not propagate remote
 record updates to the specified <ODRecordStorage>
 */
- (void)forgetRecordStorage:(ODRecordStorage *)recordStorage;

/**
 Handles remote notification payload so that all registered <ODRecordStorage>
 have a chance to updates its local storage.
 
 You are expecte to call this method when in your implementation of
 -[UIApplicationDelegate application:didReceiveRemoteNotification:].
 
 If this method returns YES, it means the remote notification
 has been handled by <ODRecordStorageCoordinator>.
 */
- (BOOL)handleUpdateWithRemoteNotification:(NSDictionary *)info;

@end
