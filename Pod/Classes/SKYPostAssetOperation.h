//
//  SKYPostAssetOperation.h
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

#import <Foundation/Foundation.h>

#import "SKYAsset.h"
#import "SKYOperation.h"

NS_ASSUME_NONNULL_BEGIN

/// Undocumented
@interface SKYPostAssetOperation : SKYOperation

/// Undocumented
- (instancetype)initWithRequest:(SKYRequest *)request NS_UNAVAILABLE;

/// Undocumented
+ (instancetype)operationWithAsset:(SKYAsset *)asset url:(NSURL *)url;

/// Undocumented
+ (instancetype)operationWithAsset:(SKYAsset *)asset
                               url:(NSURL *)url
                       extraFields:(NSDictionary<NSString *, NSObject *> *_Nullable)extraFields;

/// Undocumented
@property (nonatomic, readonly) SKYAsset *asset;
/// Undocumented
@property (nonatomic, readonly) NSURL *url;
/// Undocumented
@property (nonatomic, readonly) NSDictionary *_Nullable extraFields;

/// Undocumented
@property (nonatomic, copy) void (^_Nullable postAssetProgressBlock)(SKYAsset *_Nullable asset, double progress);
/// Undocumented
@property (nonatomic, copy) void (^_Nullable postAssetCompletionBlock)
    (SKYAsset *_Nullable asset, NSError *_Nullable operationError);

@end

NS_ASSUME_NONNULL_END
