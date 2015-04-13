//
//  ODQueryCache.h
//  Pods
//
//  Created by atwork on 13/4/15.
//
//

#import <Foundation/Foundation.h>
#import "ODDatabase.h"
#import "ODQuery.h"

@interface ODQueryCache : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 Initializes an instance of `ODQueryCache` that is suitable for caching query results
 returned by performing queries on the specified database.
 */
- (instancetype)initWithDatabase:(ODDatabase *)database NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) ODDatabase* database;

/**
 Caches the result of the specified query.
 */
- (void)cacheQuery:(ODQuery *)query results:(NSArray *)result;

/**
 Returns the cached result by specifying an `ODQuery`.
 
 If the results of a query is not cached, this method will return nil.
 */
- (NSArray *)cachedResultsWithQuery:(ODQuery *)query;

@end
