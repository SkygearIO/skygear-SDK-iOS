//
//  SKYRecordStorageFileBackedMemoryStore.m
//  SKYKit

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

#import "SKYRecordStorageFileBackedMemoryStore.h"
#import "SKYRecordDeserializer.h"
#import "SKYRecordSerializer.h"
#import "SKYRecordStorageMemoryStore_Private.h"

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
