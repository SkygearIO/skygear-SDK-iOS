//
//  SKYAssetUploadOperation.h
//  Pods
//
//  Created by Kenji Pa on 6/7/15.
//
//

#import <Foundation/Foundation.h>

#import "SKYAsset.h"
#import "SKYOperation.h"

@interface SKYUploadAssetOperation : SKYOperation

- (instancetype)initWithRequest:(SKYRequest *)request NS_UNAVAILABLE;
+ (instancetype)operationWithAsset:(SKYAsset *)asset;

@property (nonatomic, readwrite) SKYAsset *asset;

@property (nonatomic, copy) void (^uploadAssetProgressBlock)(SKYAsset *asset, double progress);
@property (nonatomic, copy) void (^uploadAssetCompletionBlock)
    (SKYAsset *asset, NSError *operationError);

@end
