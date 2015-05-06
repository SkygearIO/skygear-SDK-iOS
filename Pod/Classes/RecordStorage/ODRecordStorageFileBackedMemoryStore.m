
//
//  ODRecordStorageFileStore.m
//  Pods
//
//  Created by atwork on 6/5/15.
//
//

#import "ODRecordStorageFileBackedMemoryStore.h"
#import "ODRecordStorageMemoryStore_Private.h"
#import "ODRecordSerializer.h"
#import "ODRecordDeserializer.h"

@implementation ODRecordStorageFileBackedMemoryStore

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self prepareForPersistentStorage];
        [self load];
    }
    return self;
}

- (NSString *)persistentStoragePath
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    return path;
}

- (void)prepareForPersistentStorage
{
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:[self persistentStoragePath]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error) {
        NSLog(@"An error occurred while preparing for caching. Error: %@", error);
    }
}

- (void)load
{
    [self.records removeAllObjects];
    NSString *path = [self persistentStoragePath];
    path = [path stringByAppendingPathComponent:@"ODRecordStorage.plist"];
    NSDictionary *serializedRecords = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    ODRecordDeserializer *deserializer = [ODRecordDeserializer deserializer];
    [serializedRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        ODRecordID *recordID = [[ODRecordID alloc] initWithCanonicalString:key];
        self.records[recordID] = [deserializer recordWithDictionary:obj];
    }];
}

- (void)synchronize
{
    [self prepareForPersistentStorage];
    NSString *path = [self persistentStoragePath];
    path = [path stringByAppendingPathComponent:@"ODRecordStorage.plist"];
    
    NSMutableDictionary *serializedRecords = [[NSMutableDictionary alloc] init];
    ODRecordSerializer *serializer = [ODRecordSerializer serializer];
    [self.records enumerateKeysAndObjectsUsingBlock:^(ODRecordID *key, ODRecord *obj, BOOL *stop) {
        serializedRecords[[key canonicalString]] = [serializer dictionaryWithRecord:obj];
    }];
    [NSKeyedArchiver archiveRootObject:serializedRecords toFile:path];
}


@end
