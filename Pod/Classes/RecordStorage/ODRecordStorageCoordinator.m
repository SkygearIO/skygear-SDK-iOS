//
//  ODRecordStorageCoordinator.m
//  Pods
//
//  Created by atwork on 7/5/15.
//
//

#import "ODRecordStorageCoordinator.h"
#import "ODRecordStorage.h"
#import "ODContainer.h"
#import "ODQuery.h"
#import "ODRecordStorageMemoryStore.h"
#import "ODRecordStorageFileBackedMemoryStore.h"
#import "ODRecordStorageSqliteStore.h"
#import "ODRecordSynchronizer.h"
#import "ODSubscription.h"
#import "ODQuery+Caching.h"

NSString * const ODRecordStorageCoordinatorBackingStoreKey = @"backingStore";
NSString * const ODRecordStorageCoordinatorMemoryStore = @"MemoryStore";
NSString * const ODRecordStorageCoordinatorFileBackedMemoryStore = @"FileBackedMemoryStore";
NSString * const ODRecordStorageCoordinatorSqliteStore = @"SqliteStore";
NSString * const ODRecordStorageCoordinatorFilePath = @"filePath";

NSString *base64urlEncodeUInteger(NSUInteger i) {
    NSData *data = [NSData dataWithBytes:&i length:sizeof(i)];
    NSString *base64Encoded = [data base64EncodedStringWithOptions:0];
    return [[base64Encoded stringByReplacingOccurrencesOfString:@"+" withString:@"-"] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
}

NSString *storageFileBaseName(ODUserRecordID *userID, ODQuery *query) {
    return [NSString stringWithFormat:@"%@:%@", base64urlEncodeUInteger(userID.hash), base64urlEncodeUInteger(query.hash)];
}

@implementation ODRecordStorageCoordinator {
    NSMutableArray *_registeredRecordStorages;
    NSMapTable *_cachedStorages;
}

+ (instancetype)defaultCoordinator
{
    static ODRecordStorageCoordinator *ODRecordStorageCoordinatorInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ODRecordStorageCoordinatorInstance = [[self alloc] init];
    });
    return ODRecordStorageCoordinatorInstance;

}

- (instancetype)init
{
    return [self initWithContainer:[ODContainer defaultContainer]];
}

- (instancetype)initWithContainer:(ODContainer *)container
{
    self = [super init];
    if (self) {
        _container = container;
        _registeredRecordStorages = [NSMutableArray array];
        _cachedStorages = [NSMapTable strongToWeakObjectsMapTable];
        _purgeStoragesOnCurrentUserChanges = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(containerDidRegisterDevice:)
                                                     name:ODContainerDidRegisterDeviceNotification
                                                   object:container];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(containerDidChangeCurrentUser:)
                                                     name:ODContainerDidChangeCurrentUserNotification
                                                   object:container];
    }
    return self;
}

#pragma mark - Manage record storages

- (NSString *)storageCacheKeyWithDatabase:(ODDatabase *)database query:(ODQuery *)query
{
    return [NSString stringWithFormat:@"%@/%@", database.databaseID, query.cacheKey];
}

- (NSString *)storageCacheKeyWithRecordStorage:(ODRecordStorage *)storage
{
    return [self storageCacheKeyWithDatabase:storage.synchronizer.database
                                       query:storage.synchronizer.query];
}

- (NSArray *)registeredRecordStorages
{
    return [_registeredRecordStorages copy];
}

- (void)registerRecordStorage:(ODRecordStorage *)recordStorage
{
    [_registeredRecordStorages addObject:recordStorage];
    [_cachedStorages setObject:recordStorage
                        forKey:[self storageCacheKeyWithRecordStorage:recordStorage]];
    [self createSubscriptionWithRecordStorage:recordStorage];
}

- (void)forgetRecordStorage:(ODRecordStorage *)recordStorage
{
    [_registeredRecordStorages removeObject:recordStorage];
    [_cachedStorages removeObjectForKey:[self storageCacheKeyWithRecordStorage:recordStorage]];
}

- (void)forgetAllRecordStorages
{
    [_registeredRecordStorages enumerateObjectsUsingBlock:^(ODRecordStorage *obj, NSUInteger idx, BOOL *stop) {
        [self forgetRecordStorage:obj];
    }];
}

- (void)purgeRecordStorage:(ODRecordStorage *)recordStorage
{
    [self forgetRecordStorage:recordStorage];
    [recordStorage.backingStore purgeWithError:nil];
}

- (ODRecordStorage *)recordStorageForPrivateDatabase
{
    return [self recordStorageWithDatabase:_container.privateCloudDatabase
                                     query:nil
                                   options:nil
                                     error:nil];
}

- (id<ODRecordStorageBackingStore>)_backingStoreWith:(ODDatabase *)database query:(ODQuery *)query options:(NSDictionary *)options
{
    id<ODRecordStorageBackingStore> backingStore = nil;
    NSString *storeName = options[ODRecordStorageCoordinatorBackingStoreKey];
    if (!storeName || [storeName isEqual:ODRecordStorageCoordinatorSqliteStore]) {
        NSString *path = options[ODRecordStorageCoordinatorFilePath];
        if (!path) {
            NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
            NSString *dbName = [NSString stringWithFormat:@"%@.db", storageFileBaseName(database.container.currentUserRecordID, query)];
            path = [cachePath stringByAppendingPathComponent:dbName];
        }
        backingStore = [[ODRecordStorageSqliteStore alloc] initWithFile:path];
    } else if (!storeName || [storeName isEqual:ODRecordStorageCoordinatorFileBackedMemoryStore]) {
        NSString *path = options[ODRecordStorageCoordinatorFilePath];
        if (!path) {
            NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
            // TODO: Change file name for different database and query
            path = [cachePath stringByAppendingPathComponent:@"ODRecordStorage.plist"];
        }
        backingStore = [[ODRecordStorageFileBackedMemoryStore alloc] initWithFile:path];
    } else if ([storeName isEqual:ODRecordStorageCoordinatorMemoryStore]) {
        backingStore = [[ODRecordStorageMemoryStore alloc] init];
    } else {
        NSString *reason = [NSString stringWithFormat:@"Backing Store Name `%@` is not recognized.", storeName];
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:reason
                                     userInfo:nil];
    }
    return backingStore;
}

- (ODRecordStorage *)recordStorageWithDatabase:(ODDatabase *)database options:(NSDictionary *)options
{
    return [self recordStorageWithDatabase:database options:options error:nil];
}

- (ODRecordStorage *)recordStorageWithDatabase:(ODDatabase *)database options:(NSDictionary *)options error:(NSError **)error
{
    return [self recordStorageWithDatabase:database query:nil options:options error:nil];
}

- (ODRecordStorage *)recordStorageWithDatabase:(ODDatabase *)database query:(ODQuery *)query options:(NSDictionary *)options
{
    return [self recordStorageWithDatabase:database query:query options:options error:nil];
}

- (ODRecordStorage *)recordStorageWithDatabase:(ODDatabase *)database query:(ODQuery *)query options:(NSDictionary *)options error:(NSError **)error
{
    if (![database currentUser]) {
        if (error) {
            *error = [NSError errorWithDomain:@"ODRecordStorageErrorDomain"
                                         code:0
                                     userInfo:@{
                                                NSLocalizedDescriptionKey: @"Unable to create record storage as the database is not associated with a current user."
                                                }];
        }
        return nil;
    }
    
    NSString *cacheKey = [self storageCacheKeyWithDatabase:database query:query];
    ODRecordStorage *storage = [_cachedStorages objectForKey:cacheKey];
    if (!storage) {
        id<ODRecordStorageBackingStore> backingStore;
        backingStore = [self _backingStoreWith:database
                                         query:query
                                       options:options];
        storage = [[ODRecordStorage alloc] initWithBackingStore:backingStore];
        storage.synchronizer = [[ODRecordSynchronizer alloc] initWithContainer:self.container
                                                                      database:database
                                                                         query:query];
    }
    
    [self registerRecordStorage:storage];
    return storage;
}

- (void)createSubscriptionWithRecordStorage:(ODRecordStorage *)storage
{
    if (!self.container.currentUserRecordID) {
        NSLog(@"Unable to create subscription because current user ID is nil.");
        return;
    }
    
    if (!self.container.registeredDeviceID) {
        NSLog(@"Unable to create subscription because registered device ID is nil.");
        return;
    }
    
    ODQuery *query = storage.synchronizer.query;
    ODDatabase *database = storage.synchronizer.database;
    if (query) {
        NSString *subscriptionID = [@"ODRecordStorage-" stringByAppendingString:query.cacheKey];
        ODSubscription *subscription = [[ODSubscription alloc] initWithQuery:query
                                                              subscriptionID:subscriptionID];
        
        [database saveSubscription:subscription
                 completionHandler:^(ODSubscription *subscription, NSError *error) {
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
            [self purgeRecordStorage:(ODRecordStorage *)obj];
        } else {
            [self forgetRecordStorage:(ODRecordStorage *)obj];
        }
    }];
}

#pragma mark - Handle notifications

- (void)containerDidRegisterDevice:(NSNotification *)note
{
    [_registeredRecordStorages enumerateObjectsUsingBlock:^(ODRecordStorage *obj, NSUInteger idx, BOOL *stop) {
        [self createSubscriptionWithRecordStorage:obj];
    }];
}

- (BOOL)notification:(ODNotification *)note shouldUpdateRecordStorage:(ODRecordStorage *)storage
{
    return YES; // TODO
}

- (BOOL)handleUpdateWithRemoteNotification:(ODNotification *)note
{
    __block BOOL handled = NO;
    
    [_registeredRecordStorages enumerateObjectsUsingBlock:^(ODRecordStorage *obj, NSUInteger idx, BOOL *stop) {
        if ([self notification:note shouldUpdateRecordStorage:obj]) {
            [obj.synchronizer setUpdateAvailableWithRecordStorage:obj
                                                     notification:note];
            handled = YES;
        }
    }];
    return handled;
}

@end
