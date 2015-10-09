//
//  SKYQuery+Caching.h
//  Pods
//
//  Created by atwork on 13/4/15.
//
//

#import "SKYQuery.h"

@interface SKYQuery (Caching)

/**
 Returns the cache key that can be used as an identifier to cache the result
 of this query.
 
 The cache key is expected to be consistent for `SKYQuery`s that are equal.
 */
@property (nonatomic, readonly) NSString *cacheKey;

@end
