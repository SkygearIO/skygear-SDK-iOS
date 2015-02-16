//
//  ODAsset.h
//  askq
//
//  Created by Kenji Pa on 19/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ODAsset : NSObject

- (instancetype)initWithFileURL:(NSURL *)fileURL;
- (instancetype)initWithData:(NSData *)data;

@property (nonatomic, readonly, copy) NSURL *fileURL;

@end
