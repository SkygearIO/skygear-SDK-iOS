//
//  SKYQueryCache.h
//  Pods
//
//  Created by atwork on 13/4/15.
//
//

#import <Foundation/Foundation.h>
#import "SKYDatabase.h"
#import "SKYQuery.h"

@interface SKYQueryCache : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 Initializes an instance of `SKYQueryCache` that is suitable for caching query results
 returned by performing queries on the specified database.
 */
- (instancetype)initWithDatabase:(SKYDatabase *)database NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) SKYDatabase *database;

/**
 Caches the result of the specified query.
 */
- (void)cacheQuery:(SKYQuery *)query results:(NSArray *)result;

/**
 Returns the cached result by specifying an `SKYQuery`.

 If the results of a query is not cached, this method will return nil.
 */
- (NSArray *)cachedResultsWithQuery:(SKYQuery *)query;

@end
