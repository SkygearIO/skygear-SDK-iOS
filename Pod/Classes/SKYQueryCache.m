//
//  SKYQueryCache.m
//  Pods
//
//  Created by atwork on 13/4/15.
//
//

#import "SKYQueryCache.h"
#import "SKYRecordSerializer.h"
#import "SKYRecordDeserializer.h"
#import "SKYQuery+Caching.h"

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
    [NSKeyedArchiver archiveRootObject:toBeCached
                                toFile:[self cacheFilePathWithQuery:query]];
}

- (NSArray *)cachedResultsWithQuery:(SKYQuery *)query
{
    NSMutableArray *cachedResults = [NSMutableArray array];
    SKYRecordDeserializer *deserializer = [SKYRecordDeserializer deserializer];
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
