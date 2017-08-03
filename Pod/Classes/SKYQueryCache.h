//
//  SKYQueryCache.h
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

#import "SKYDatabase.h"
#import "SKYQuery.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Undocumented
@interface SKYQueryCache : NSObject

/// Undocumented
- (instancetype)init NS_UNAVAILABLE;

/**
 Initializes an instance of `SKYQueryCache` that is suitable for caching query results
 returned by performing queries on the specified database.
 */
- (instancetype)initWithDatabase:(SKYDatabase *)database NS_DESIGNATED_INITIALIZER;

/// Undocumented
@property (nonatomic, readonly) SKYDatabase *database;

/**
 Caches the result of the specified query.
 */
- (void)cacheQuery:(SKYQuery *)query results:(NSArray *)result;

/**
 Returns the cached result by specifying an `SKYQuery`.

 If the results of a query is not cached, this method will return nil.
 */
- (NSArray *_Nullable)cachedResultsWithQuery:(SKYQuery *)query;

@end

NS_ASSUME_NONNULL_END
