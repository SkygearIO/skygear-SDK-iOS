//
//  ODDownloadAssetOperation.h
//  Pods
//
//  Created by Kenji Pa on 7/7/15.
//
//

#import "ODOperation.h"

#import "ODAsset.h"

@interface ODDownloadAssetOperation : ODOperation

- (instancetype)initWithRequest:(ODRequest *)request NS_UNAVAILABLE;
+ (instancetype)operationWithAsset:(ODAsset *)asset;

@property (nonatomic, copy) void(^downloadAssetProgressBlock)(ODAsset *asset, double progress);
@property (nonatomic, copy) void(^downloadAssetCompletionBlock)(ODAsset *asset, NSData *data, NSError *operationError);

@end
