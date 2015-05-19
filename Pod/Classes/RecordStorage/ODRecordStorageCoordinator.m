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
#import "ODRecordStorageMemoryStore.h"
#import "ODRecordStorageFileBackedMemoryStore.h"
#import "ODRecordSynchronizer.h"

NSString * const ODRecordStorageCoordinatorBackingStoreKey = @"backingStore";
NSString * const ODRecordStorageCoordinatorMemoryStore = @"MemoryStore";
NSString * const ODRecordStorageCoordinatorFileBackedMemoryStore = @"FileBackedMemoryStore";
NSString * const ODRecordStorageCoordinatorFilePath = @"filePath";

@implementation ODRecordStorageCoordinator {
    NSMutableArray *_recordStorages;
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
        _recordStorages = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Manage record storages

- (NSArray *)recordStorages
{
    return [_recordStorages copy];
}

- (void)registerRecordStorage:(ODRecordStorage *)recordStorage
{
    [_recordStorages addObject:recordStorage];
}

- (void)forgetRecordStorage:(ODRecordStorage *)recordStorage
{
    [_recordStorages removeObject:recordStorage];
}

- (ODRecordStorage *)recordStorageForPrivateDatabase
{
    return [self recordStorageWithDatabase:_container.privateCloudDatabase
                                     query:nil
                                   options:nil];
}

- (id<ODRecordStorageBackingStore>)_backingStoreWith:(ODDatabase *)database query:(ODQuery *)query options:(NSDictionary *)options
{
    id<ODRecordStorageBackingStore> backingStore = nil;
    NSString *storeName = options[ODRecordStorageCoordinatorBackingStoreKey];
    if (!storeName || [storeName isEqual:ODRecordStorageCoordinatorFileBackedMemoryStore]) {
        NSString *path = options[ODRecordStorageCoordinatorFilePath];
        if (!path) {
            NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
            // TODO: Change file name for different database and query
            path = [cachePath stringByAppendingString:@"ODRecordStorage.plist"];
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
    return [self recordStorageWithDatabase:database query:nil options:options];
}

- (ODRecordStorage *)recordStorageWithDatabase:(ODDatabase *)database query:(ODQuery *)query options:(NSDictionary *)options
{
    id<ODRecordStorageBackingStore> backingStore;
    backingStore = [self _backingStoreWith:database
                                     query:query
                                   options:options];
    ODRecordStorage *storage = [[ODRecordStorage alloc] initWithBackingStore:backingStore];
    storage.synchronizer = [[ODRecordSynchronizer alloc] initWithContainer:self.container
                                                                  database:database
                                                                     query:query];
    [self registerRecordStorage:storage];
    return storage;
}

#pragma mark - Handle notifications

- (BOOL)handleUpdateWithRemoteNotification:(NSDictionary *)info
{
    __block BOOL handled = NO;
    
    // TODO: Check if the notification info is for ODRecordStorage. If not, maybe we
    // should not blindly pass it to ODRecordStorage.
    
    [_recordStorages enumerateObjectsUsingBlock:^(ODRecordStorage *obj, NSUInteger idx, BOOL *stop) {
        if (!obj.enabled) {
            return;
        }
        BOOL handledByStorage = [obj handleUpdateWithRemoteNotification:info];
        handled = handled || handledByStorage;
    }];
    return handled;
}

@end
