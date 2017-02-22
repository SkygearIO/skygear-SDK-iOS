//
//  SKYRecordStorageCoordinator.m
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

#import "SKYRecordStorageCoordinator.h"
#import "SKYContainer.h"
#import "SKYQuery+Caching.h"
#import "SKYQuery.h"
#import "SKYRecordStorage.h"
#import "SKYRecordStorageFileBackedMemoryStore.h"
#import "SKYRecordStorageMemoryStore.h"
#import "SKYRecordStorageSqliteStore.h"
#import "SKYRecordSynchronizer.h"
#import "SKYSubscription.h"

NSString *const SKYRecordStorageCoordinatorBackingStoreKey = @"backingStore";
NSString *const SKYRecordStorageCoordinatorMemoryStore = @"MemoryStore";
NSString *const SKYRecordStorageCoordinatorFileBackedMemoryStore = @"FileBackedMemoryStore";
NSString *const SKYRecordStorageCoordinatorSqliteStore = @"SqliteStore";
NSString *const SKYRecordStorageCoordinatorFilePath = @"filePath";

NSString *base64urlEncodeUInteger(NSUInteger i)
{
    NSData *data = [NSData dataWithBytes:&i length:sizeof(i)];
    NSString *base64Encoded = [data base64EncodedStringWithOptions:0];
    return [[base64Encoded stringByReplacingOccurrencesOfString:@"+" withString:@"-"]
        stringByReplacingOccurrencesOfString:@"/"
                                  withString:@"_"];
}

NSString *storageFileBaseName(NSString *userID, SKYQuery *query)
{
    return [NSString stringWithFormat:@"%@:%@", base64urlEncodeUInteger(userID.hash),
                                      base64urlEncodeUInteger(query.hash)];
}

@implementation SKYRecordStorageCoordinator {
    NSMutableArray *_registeredRecordStorages;
    NSMapTable *_cachedStorages;
}

+ (instancetype)defaultCoordinator
{
    static SKYRecordStorageCoordinator *SKYRecordStorageCoordinatorInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SKYRecordStorageCoordinatorInstance = [[self alloc] init];
    });
    return SKYRecordStorageCoordinatorInstance;
}

- (instancetype)init
{
    return [self initWithContainer:[SKYContainer defaultContainer]];
}

- (instancetype)initWithContainer:(SKYContainer *)container
{
    self = [super init];
    if (self) {
        _container = container;
        _registeredRecordStorages = [NSMutableArray array];
        _cachedStorages = [NSMapTable strongToWeakObjectsMapTable];
        _purgeStoragesOnCurrentUserChanges = YES;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(containerDidRegisterDevice:)
                                                     name:SKYContainerDidRegisterDeviceNotification
                                                   object:container];
        [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(containerDidChangeCurrentUser:)
                   name:SKYContainerDidChangeCurrentUserNotification
                 object:container];
    }
    return self;
}

#pragma mark - Manage record storages

- (NSString *)storageCacheKeyWithDatabase:(SKYDatabase *)database query:(SKYQuery *)query
{
    return [NSString stringWithFormat:@"%@/%@", database.databaseID, query.cacheKey];
}

- (NSString *)storageCacheKeyWithRecordStorage:(SKYRecordStorage *)storage
{
    return [self storageCacheKeyWithDatabase:storage.synchronizer.database
                                       query:storage.synchronizer.query];
}

- (NSArray *)registeredRecordStorages
{
    return [_registeredRecordStorages copy];
}

- (void)registerRecordStorage:(SKYRecordStorage *)recordStorage
{
    [_registeredRecordStorages addObject:recordStorage];
    [_cachedStorages setObject:recordStorage
                        forKey:[self storageCacheKeyWithRecordStorage:recordStorage]];
    [self createSubscriptionWithRecordStorage:recordStorage];
}

- (void)forgetRecordStorage:(SKYRecordStorage *)recordStorage
{
    [_registeredRecordStorages removeObject:recordStorage];
    [_cachedStorages removeObjectForKey:[self storageCacheKeyWithRecordStorage:recordStorage]];
}

- (void)forgetAllRecordStorages
{
    [_registeredRecordStorages
        enumerateObjectsUsingBlock:^(SKYRecordStorage *obj, NSUInteger idx, BOOL *stop) {
            [self forgetRecordStorage:obj];
        }];
}

- (void)purgeRecordStorage:(SKYRecordStorage *)recordStorage
{
    [self forgetRecordStorage:recordStorage];
    [recordStorage.backingStore purgeWithError:nil];
}

- (SKYRecordStorage *)recordStorageForPrivateDatabase
{
    return [self recordStorageWithDatabase:_container.privateCloudDatabase
                                     query:nil
                                   options:nil
                                     error:nil];
}

- (id<SKYRecordStorageBackingStore>)_backingStoreWith:(SKYDatabase *)database
                                                query:(SKYQuery *)query
                                              options:(NSDictionary *)options
{
    id<SKYRecordStorageBackingStore> backingStore = nil;
    NSString *storeName = options[SKYRecordStorageCoordinatorBackingStoreKey];
    if (!storeName || [storeName isEqual:SKYRecordStorageCoordinatorSqliteStore]) {
        NSString *path = options[SKYRecordStorageCoordinatorFilePath];
        if (!path) {
            NSString *cachePath =
                NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
            NSString *dbName = [NSString
                stringWithFormat:@"%@.db", storageFileBaseName(
                                               database.container.currentUserRecordID, query)];
            path = [cachePath stringByAppendingPathComponent:dbName];
        }
        backingStore = [[SKYRecordStorageSqliteStore alloc] initWithFile:path];
    } else if (!storeName || [storeName isEqual:SKYRecordStorageCoordinatorFileBackedMemoryStore]) {
        NSString *path = options[SKYRecordStorageCoordinatorFilePath];
        if (!path) {
            NSString *cachePath =
                NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
            // TODO: Change file name for different database and query
            path = [cachePath stringByAppendingPathComponent:@"SKYRecordStorage.plist"];
        }
        backingStore = [[SKYRecordStorageFileBackedMemoryStore alloc] initWithFile:path];
    } else if ([storeName isEqual:SKYRecordStorageCoordinatorMemoryStore]) {
        backingStore = [[SKYRecordStorageMemoryStore alloc] init];
    } else {
        NSString *reason =
            [NSString stringWithFormat:@"Backing Store Name `%@` is not recognized.", storeName];
        @throw
            [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
    }
    return backingStore;
}

- (SKYRecordStorage *)recordStorageWithDatabase:(SKYDatabase *)database
                                        options:(NSDictionary *)options
{
    return [self recordStorageWithDatabase:database options:options error:nil];
}

- (SKYRecordStorage *)recordStorageWithDatabase:(SKYDatabase *)database
                                        options:(NSDictionary *)options
                                          error:(NSError **)error
{
    return [self recordStorageWithDatabase:database query:nil options:options error:nil];
}

- (SKYRecordStorage *)recordStorageWithDatabase:(SKYDatabase *)database
                                          query:(SKYQuery *)query
                                        options:(NSDictionary *)options
{
    return [self recordStorageWithDatabase:database query:query options:options error:nil];
}

- (SKYRecordStorage *)recordStorageWithDatabase:(SKYDatabase *)database
                                          query:(SKYQuery *)query
                                        options:(NSDictionary *)options
                                          error:(NSError **)error
{
    if (![database currentUser]) {
        if (error) {
            *error = [NSError errorWithDomain:@"SKYRecordStorageErrorDomain"
                                         code:0
                                     userInfo:@{
                                         NSLocalizedDescriptionKey :
                                             @"Unable to create record storage as the database is "
                                             @"not associated with a current user."
                                     }];
        }
        return nil;
    }

    NSString *cacheKey = [self storageCacheKeyWithDatabase:database query:query];
    SKYRecordStorage *storage = [_cachedStorages objectForKey:cacheKey];
    if (!storage) {
        id<SKYRecordStorageBackingStore> backingStore;
        backingStore = [self _backingStoreWith:database query:query options:options];
        storage = [[SKYRecordStorage alloc] initWithBackingStore:backingStore];
        storage.synchronizer = [[SKYRecordSynchronizer alloc] initWithContainer:self.container
                                                                       database:database
                                                                          query:query];
    }

    [self registerRecordStorage:storage];
    return storage;
}

- (void)createSubscriptionWithRecordStorage:(SKYRecordStorage *)storage
{
    if (!self.container.currentUserRecordID) {
        NSLog(@"Unable to create subscription because current user ID is nil.");
        return;
    }

    if (!self.container.registeredDeviceID) {
        NSLog(@"Unable to create subscription because registered device ID is nil.");
        return;
    }

    SKYQuery *query = storage.synchronizer.query;
    SKYDatabase *database = storage.synchronizer.database;
    if (query) {
        NSString *subscriptionID = [@"SKYRecordStorage-" stringByAppendingString:query.cacheKey];
        SKYSubscription *subscription =
            [[SKYSubscription alloc] initWithQuery:query subscriptionID:subscriptionID];

        [database saveSubscription:subscription
                 completionHandler:^(SKYSubscription *subscription, NSError *error) {
                     if (error) {
                         NSLog(@"Failed to subscribe for my note: %@", error);
                         return;
                     }

                     NSLog(@"Subscription successful.");
                 }];
    }
}

- (void)containerDidChangeCurrentUser:(NSNotification *)note
{
    BOOL purge = [self isPurgeStoragesOnCurrentUserChanges];
    [_registeredRecordStorages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (purge) {
            [self purgeRecordStorage:(SKYRecordStorage *)obj];
        } else {
            [self forgetRecordStorage:(SKYRecordStorage *)obj];
        }
    }];
}

#pragma mark - Handle notifications

- (void)containerDidRegisterDevice:(NSNotification *)note
{
    [_registeredRecordStorages
        enumerateObjectsUsingBlock:^(SKYRecordStorage *obj, NSUInteger idx, BOOL *stop) {
            [self createSubscriptionWithRecordStorage:obj];
        }];
}

- (BOOL)notification:(SKYNotification *)note shouldUpdateRecordStorage:(SKYRecordStorage *)storage
{
    return YES; // TODO
}

- (BOOL)handleUpdateWithRemoteNotification:(SKYNotification *)note
{
    __block BOOL handled = NO;

    [_registeredRecordStorages
        enumerateObjectsUsingBlock:^(SKYRecordStorage *obj, NSUInteger idx, BOOL *stop) {
            if ([self notification:note shouldUpdateRecordStorage:obj]) {
                [obj.synchronizer setUpdateAvailableWithRecordStorage:obj notification:note];
                handled = YES;
            }
        }];
    return handled;
}

@end
