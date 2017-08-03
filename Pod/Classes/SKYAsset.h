//
//  SKYAsset.h
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

NS_ASSUME_NONNULL_BEGIN

/// Undocumented
@interface SKYAsset : NSObject <NSCopying>

/// Undocumented
+ (instancetype)assetWithName:(NSString *)name fileURL:(NSURL *)fileURL;
/// Undocumented
+ (instancetype)assetWithName:(NSString *)name data:(NSData *)data;
/// Undocumented
+ (instancetype)assetWithFileURL:(NSURL *)fileURL;
/// Undocumented
+ (instancetype)assetWithData:(NSData *)data;

/// Undocumented
@property (nonatomic, readonly, copy) NSString *name;
/// Undocumented
@property (nonatomic, readonly, copy) NSURL *url;
/// Undocumented
@property (nonatomic, readonly, copy) NSNumber *fileSize;

/**
 The MIME type of the asset when the MIME type is known.

 When uploading asset, the MIME type stored in this property will be used to set the asset
 content type.
 */
@property (nonatomic, readwrite, copy) NSString *mimeType;

@end

NS_ASSUME_NONNULL_END
