//
//  SKYAsset.m
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

#import "SKYAsset.h"
#import <MagicKit/MagicKit.h>

@interface SKYAsset ()

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithName:(NSString *)name url:(NSURL *)url;

@property (nonatomic, readwrite, copy) NSString *name;
@property (nonatomic, readwrite, copy) NSURL *url;
@property (nonatomic, readwrite, copy) NSNumber *fileSize;

@end

@implementation SKYAsset

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name url:(NSURL *)url
{
    self = [self init];
    if (self) {
        _name = [name copy];
        _url = [url copy];

        if (url.isFileURL) {
            _fileSize = [self deriveFileSize];
        }

        _mimeType = [self deriveMimeType];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSString *name = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"name"];
    if (!name) {
        return nil;
    }

    NSURL *url = [aDecoder decodeObjectOfClass:[NSURL class] forKey:@"url"];
    self = [self initWithName:name url:url];
    if (self) {
        NSNumber *fileSize = [aDecoder decodeObjectOfClass:[NSNumber class] forKey:@"fileSize"];
        if (fileSize.intValue > 0) {
            self.fileSize = fileSize;
        }

        self.mimeType = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"mimeType"];
    }

    return self;
}

+ (instancetype)assetWithName:(NSString *)name url:(NSURL *)url
{
    return [[self alloc] initWithName:name url:url];
}

+ (instancetype)assetWithName:(NSString *)name fileURL:(NSURL *)fileURL
{
    return [[self alloc] initWithName:name url:fileURL];
}

+ (instancetype)assetWithName:(NSString *)name data:(NSData *)data
{
    NSString *fileName = [[NSProcessInfo processInfo] globallyUniqueString];
    NSURL *fileURL =
        [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
    [data writeToURL:fileURL atomically:NO];

    return [[self alloc] initWithName:name url:fileURL];
}

+ (instancetype)assetWithFileURL:(NSURL *)fileURL
{
    return [[self alloc] initWithName:fileURL.lastPathComponent url:fileURL];
}

+ (instancetype)assetWithData:(NSData *)data
{
    return
        [[self class] assetWithName:[[NSProcessInfo processInfo] globallyUniqueString] data:data];
}

- (id)copyWithZone:(NSZone *)zone
{
    SKYAsset *asset = [[SKYAsset alloc] init];
    if (asset) {
        asset->_name = [self.name copyWithZone:zone];
        asset->_url = [self.url copyWithZone:zone];
        asset->_fileSize = [self.fileSize copyWithZone:zone];
        asset->_mimeType = [self.mimeType copyWithZone:zone];
    }
    return asset;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.fileSize forKey:@"fileSize"];
    [aCoder encodeObject:self.mimeType forKey:@"mimeType"];
}

// derive fileSize used in SKYGetAssetPostRequestOperation
- (NSNumber *)deriveFileSize
{
    NSNumber *fileSize;

    if (!_url.isFileURL) {
        NSLog(@"Failed obtain file size in %@: not a file in local filesystem", _url);
    }

    NSError *error;
    [_url getResourceValue:&fileSize forKey:NSURLFileSizeKey error:&error];
    if (error) {
        NSLog(@"Failed obtain file size in %@: %@", _url, error);
        fileSize = [NSNumber numberWithInteger:0];
    }

    return fileSize;
}

// derive mimeType used in SKYGetAssetPostRequestOperation
- (NSString *)deriveMimeType
{
    NSString *mimeType = [GEMagicKit magicForFileAtURL:_url].mimeType;

    // Remove charset
    NSArray<NSString *> *split = [mimeType componentsSeparatedByString:@";"];
    return split[0];
}

@end
