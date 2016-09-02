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

@interface SKYPostAssetOperation : SKYOperation
NS_ASSUME_NONNULL_BEGIN

- (instancetype)initWithRequest:(SKYRequest *)request NS_UNAVAILABLE;

+ (instancetype)operationWithAsset:(SKYAsset *)asset url:(NSURL *)url;

+ (instancetype)operationWithAsset:(SKYAsset *)asset
                               url:(NSURL *)url
                       extraFields:(nullable NSDictionary<NSString *, NSObject *> *)extraFields;

@property (nonatomic, readonly) SKYAsset *asset;
@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSDictionary *extraFields;

@property (nonatomic, copy) void (^_Nullable postAssetProgressBlock)
    (SKYAsset *asset, double progress);
@property (nonatomic, copy) void (^_Nullable postAssetCompletionBlock)
    (SKYAsset *asset, NSError *_Nullable operationError);

NS_ASSUME_NONNULL_END
@end
