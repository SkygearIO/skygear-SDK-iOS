//
//  SKYAsset_Private.h
//  Pods
//
//  Created by Kenji Pa on 6/7/15.
//
//

#import <Foundation/Foundation.h>

#import "SKYAsset.h"

@interface SKYAsset ()

+ (instancetype)assetWithName:(NSString *)name url:(NSURL *)url;

@property (nonatomic, readwrite, copy) NSString *name;
@property (nonatomic, readwrite, copy) NSURL *url;
@property (nonatomic, readonly, copy) NSNumber *fileSize;

@end
