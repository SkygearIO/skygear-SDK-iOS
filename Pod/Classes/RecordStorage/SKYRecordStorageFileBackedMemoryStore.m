
//
//  SKYRecordStorageFileStore.m
//  Pods
//
//  Created by atwork on 6/5/15.
//
//

#import "SKYRecordStorageFileBackedMemoryStore.h"
#import "SKYRecordStorageMemoryStore_Private.h"
#import "SKYRecordSerializer.h"
#import "SKYRecordDeserializer.h"

@implementation SKYRecordStorageFileBackedMemoryStore {
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
    [self.changes removeAllObjects];
    [self.localRecords removeAllObjects];
    NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithFile:_path];
    SKYRecordDeserializer *deserializer = [SKYRecordDeserializer deserializer];
    [dict[@"records"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        SKYRecordID *recordID = [[SKYRecordID alloc] initWithCanonicalString:key];
        self.records[recordID] = [deserializer recordWithDictionary:obj];
    }];
    [dict[@"localRecords"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        SKYRecordID *recordID = [[SKYRecordID alloc] initWithCanonicalString:key];
        if ([[NSNull null] isEqual:obj]) {
            self.localRecords[recordID] = obj;
        } else {
            self.localRecords[recordID] = [deserializer recordWithDictionary:obj];
        }
    }];
    [self.changes addObjectsFromArray:dict[@"changes"]];
}

- (BOOL)purgeWithError:(NSError *__autoreleasing *)error
{
    [super purgeWithError:nil];
    return [[NSFileManager defaultManager] removeItemAtPath:_path error:error];
}

- (void)synchronize
{
    NSMutableDictionary *serializedRecords = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *serializedLocalRecords = [[NSMutableDictionary alloc] init];
    SKYRecordSerializer *serializer = [SKYRecordSerializer serializer];
    [self.records
        enumerateKeysAndObjectsUsingBlock:^(SKYRecordID *key, SKYRecord *obj, BOOL *stop) {
            serializedRecords[[key canonicalString]] = [serializer dictionaryWithRecord:obj];
        }];
    [self.localRecords enumerateKeysAndObjectsUsingBlock:^(SKYRecordID *key, SKYRecord *obj,
                                                           BOOL *stop) {
        if ([[NSNull null] isEqual:obj]) {
            serializedLocalRecords[[key canonicalString]] = obj;
        } else {
            serializedLocalRecords[[key canonicalString]] = [serializer dictionaryWithRecord:obj];
        }
    }];
    [NSKeyedArchiver archiveRootObject:@{
        @"records" : serializedRecords,
        @"changes" : self.changes,
        @"localRecords" : serializedLocalRecords,
    }
                                toFile:_path];
}

@end
