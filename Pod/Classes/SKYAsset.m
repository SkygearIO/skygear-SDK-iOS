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
#import <MobileCoreServices/MobileCoreServices.h>

@interface SKYAsset ()

- (instancetype)initWithName:(NSString *)name url:(NSURL *)url NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithName:(NSString *)name fileURL:(NSURL *)fileURL;
- (instancetype)initWithName:(NSString *)name data:(NSData *)data;
- (instancetype)initWithFileURL:(NSURL *)fileURL;
- (instancetype)initWithData:(NSData *)data;

@property (nonatomic, readwrite, copy) NSString *name;
@property (nonatomic, readwrite, copy) NSURL *url;
@property (nonatomic, readwrite, copy) NSNumber *fileSize;

@end

@implementation SKYAsset

- (instancetype)initWithName:(NSString *)name url:(NSURL *)url
{
    self = [super init];
    if (self) {
        _name = [name copy];
        _url = [url copy];

        // derive fileSize used in SKYGetAssetPostRequestOperation
        if (_url.isFileURL) {
            NSNumber *fileSize;
            NSError *error;
            [_url getResourceValue:&fileSize forKey:NSURLFileSizeKey error:&error];
            if (error) {
                NSLog(@"Failed obtain file size in %@: %@", _url, error);
            }
            _fileSize = fileSize;
        }

        // derive mimeType used in SKYGetAssetPostRequestOperation
        CFStringRef extension = (__bridge CFStringRef)_url.pathExtension;
        CFStringRef UTI =
            UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
        if (UTI) {
            NSString *mimetype =
                CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
            if (mimetype) {
                _mimeType = mimetype;
            } else {
                NSLog(@"Cannot derive mimeType");
            }

            CFRelease(UTI);
        } else {
            NSLog(@"Cannot derive mimeType since UTI == NULL");
        }
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name fileURL:(NSURL *)fileURL
{
    return [self initWithName:name url:fileURL];
}

- (instancetype)initWithName:(NSString *)name data:(NSData *)data
{
    NSString *fileName = [[NSProcessInfo processInfo] globallyUniqueString];
    NSURL *fileURL =
        [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
    [data writeToURL:fileURL atomically:NO];

    return [self initWithName:name fileURL:fileURL];
}

- (instancetype)initWithFileURL:(NSURL *)fileURL
{
    return [self initWithName:fileURL.lastPathComponent fileURL:fileURL];
}

- (instancetype)initWithData:(NSData *)data
{
    return [self initWithName:[[NSProcessInfo processInfo] globallyUniqueString] data:data];
}

+ (instancetype)assetWithName:(NSString *)name url:(NSURL *)url
{
    return [[self alloc] initWithName:name url:url];
}

+ (instancetype)assetWithName:(NSString *)name fileURL:(NSURL *)fileURL
{
    return [[self alloc] initWithName:name fileURL:fileURL];
}

+ (instancetype)assetWithName:(NSString *)name data:(NSData *)data
{
    return [[self alloc] initWithName:name data:data];
}

+ (instancetype)assetWithFileURL:(NSURL *)fileURL
{
    return [[self alloc] initWithFileURL:fileURL];
}

+ (instancetype)assetWithData:(NSData *)data
{
    return [[self alloc] initWithData:data];
}

@end
