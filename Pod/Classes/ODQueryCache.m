//
//  ODQueryCache.m
//  Pods
//
//  Created by atwork on 13/4/15.
//
//

#import "ODQueryCache.h"
#import "ODRecordSerializer.h"
#import "ODRecordDeserializer.h"
#import "ODQuery+Caching.h"

@implementation ODQueryCache

- (instancetype)initWithDatabase:(ODDatabase *)database
{
    self = [super init];
    if (self) {
        _database = database;
        [self prepareForCaching];
    }
    return self;
}

- (NSString *)cacheKeyWithQuery:(ODQuery *)query
{
    return [query cacheKey];
}

- (NSString *)cacheDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *subpath = [NSString stringWithFormat:@"ODQueryCache/%@", self.database.databaseID];
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

- (NSString *)cacheFilePathWithQuery:(ODQuery *)query
{
    NSString *cacheKey = [self cacheKeyWithQuery:query];
    return [[self cacheDirectoryPath] stringByAppendingPathComponent:cacheKey];
}

- (void)cacheQuery:(ODQuery *)query results:(NSArray *)results
{
    ODRecordSerializer *serializer = [ODRecordSerializer serializer];
    NSMutableArray *toBeCached = [NSMutableArray array];
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [toBeCached addObject:[serializer dictionaryWithRecord:obj]];
    }];
    [NSKeyedArchiver archiveRootObject:toBeCached
                                toFile:[self cacheFilePathWithQuery:query]];
}

- (NSArray *)cachedResultsWithQuery:(ODQuery *)query
{
    NSMutableArray *cachedResults = [NSMutableArray array];
    ODRecordDeserializer *deserializer = [ODRecordDeserializer deserializer];
    NSArray *results = [NSKeyedUnarchiver unarchiveObjectWithFile:
                        [self cacheFilePathWithQuery:query]];
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
