//
//  ODAssetUploadOperation.h
//  Pods
//
//  Created by Kenji Pa on 6/7/15.
//
//

#import <Foundation/Foundation.h>

#import "ODAsset.h"
#import "ODOperation.h"

@interface ODUploadAssetOperation : ODOperation

- (instancetype)initWithRequest:(ODRequest *)request NS_UNAVAILABLE;
+ (instancetype)operationWithAsset:(ODAsset *)asset;

@property (nonatomic, readwrite) ODAsset *asset;

@property (nonatomic, copy) void(^uploadAssetProgressBlock)(ODAsset *asset, double progress);
@property (nonatomic, copy) void(^uploadAssetCompletionBlock)(ODAsset *asset, NSError *operationError);

@end
