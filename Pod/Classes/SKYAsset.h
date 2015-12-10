//
//  SKYAsset.h
//  askq
//
//  Created by Kenji Pa on 19/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKYAsset : NSObject

+ (instancetype)assetWithName:(NSString *)name fileURL:(NSURL *)fileURL;
+ (instancetype)assetWithName:(NSString *)name data:(NSData *)data;
+ (instancetype)assetWithFileURL:(NSURL *)fileURL;
+ (instancetype)assetWithData:(NSData *)data;

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSURL *url;

- (instancetype)init NS_UNAVAILABLE;

@end
