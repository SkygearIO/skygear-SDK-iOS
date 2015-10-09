//
//  SKYDownloadAssetOperation.h
//  Pods
//
//  Created by Kenji Pa on 7/7/15.
//
//

#import "SKYOperation.h"

#import "SKYAsset.h"

@interface SKYDownloadAssetOperation : SKYOperation

- (instancetype)initWithRequest:(SKYRequest *)request NS_UNAVAILABLE;
+ (instancetype)operationWithAsset:(SKYAsset *)asset;

@property (nonatomic, copy) void(^downloadAssetProgressBlock)(SKYAsset *asset, double progress);
@property (nonatomic, copy) void(^downloadAssetCompletionBlock)(SKYAsset *asset, NSData *data, NSError *operationError);

@end
