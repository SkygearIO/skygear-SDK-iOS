
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

@implementation ODRecordStorageFileBackedMemoryStore {
    NSString *_path;
}

- (instancetype)initWithFile:(NSString *)path
{
    self = [super init];
    if (self) {
        _path = path;
        [self prepareForPersistentStorage];
        [self load];
    }
    return self;
}

- (void)prepareForPersistentStorage
{
    NSString *directoryPath = [_path stringByDeletingLastPathComponent];
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
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
    NSDictionary *serializedRecords = [NSKeyedUnarchiver unarchiveObjectWithFile:_path];
    ODRecordDeserializer *deserializer = [ODRecordDeserializer deserializer];
    [serializedRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        ODRecordID *recordID = [[ODRecordID alloc] initWithCanonicalString:key];
        self.records[recordID] = [deserializer recordWithDictionary:obj];
    }];
}

- (void)synchronize
{
    NSMutableDictionary *serializedRecords = [[NSMutableDictionary alloc] init];
    ODRecordSerializer *serializer = [ODRecordSerializer serializer];
    [self.records enumerateKeysAndObjectsUsingBlock:^(ODRecordID *key, ODRecord *obj, BOOL *stop) {
        serializedRecords[[key canonicalString]] = [serializer dictionaryWithRecord:obj];
    }];
    [NSKeyedArchiver archiveRootObject:serializedRecords toFile:_path];
}


@end
