//
//  SKYQuery+Caching.h
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

#import "SKYQuery.h"

NS_ASSUME_NONNULL_BEGIN

/// Undocumented
@interface SKYQuery (Caching)

/**
 Returns the cache key that can be used as an identifier to cache the result
 of this query.

 The cache key is expected to be consistent for `SKYQuery`s that are equal.
 */
@property (nonatomic, readonly) NSString *cacheKey;

@end

NS_ASSUME_NONNULL_END
