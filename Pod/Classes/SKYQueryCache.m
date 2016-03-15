//
//  SKYQueryCache.m
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

#import "SKYQueryCache.h"
#import "SKYQuery+Caching.h"
#import "SKYRecordDeserializer.h"
#import "SKYRecordSerializer.h"

@implementation SKYQueryCache

- (instancetype)initWithDatabase:(SKYDatabase *)database
{
    self = [super init];
    if (self) {
        _database = database;
        [self prepareForCaching];
    }
    return self;
}

- (NSString *)cacheKeyWithQuery:(SKYQuery *)query
{
    return [query cacheKey];
}

- (NSString *)cacheDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *subpath = [NSString stringWithFormat:@"SKYQueryCache/%@", self.database.databaseID];
    return paths.count > 0 ? [paths[0] stringByAppendingPathComponent:subpath] : nil;
}

- (void)prepareForCaching
{
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:[self cacheDirectoryPath]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error) {
        NSLog(@"An error occurred while preparing for caching. Error: %@", error);
    }
}

- (NSString *)cacheFilePathWithQuery:(SKYQuery *)query
{
    NSString *cacheKey = [self cacheKeyWithQuery:query];
    return [[self cacheDirectoryPath] stringByAppendingPathComponent:cacheKey];
}

- (void)cacheQuery:(SKYQuery *)query results:(NSArray *)results
{
    SKYRecordSerializer *serializer = [SKYRecordSerializer serializer];
    NSMutableArray *toBeCached = [NSMutableArray array];
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [toBeCached addObject:[serializer dictionaryWithRecord:obj]];
    }];
    [NSKeyedArchiver archiveRootObject:toBeCached toFile:[self cacheFilePathWithQuery:query]];
}

- (NSArray *)cachedResultsWithQuery:(SKYQuery *)query
{
    NSMutableArray *cachedResults = [NSMutableArray array];
    SKYRecordDeserializer *deserializer = [SKYRecordDeserializer deserializer];
    NSArray *results =
        [NSKeyedUnarchiver unarchiveObjectWithFile:[self cacheFilePathWithQuery:query]];
    if ([results isKindOfClass:[NSArray class]]) {
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [cachedResults addObject:[deserializer recordWithDictionary:obj]];
        }];
        return [cachedResults copy];
    } else {
        return nil;
    }
}

@end
