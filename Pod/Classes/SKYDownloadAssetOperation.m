//
//  SKYDownloadAssetOperation.m
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

#import "SKYDownloadAssetOperation.h"

#import "SKYAsset_Private.h"

@interface SKYDownloadAssetOperation ()

@property (nonatomic, readwrite) SKYAsset *asset;
@property (nonatomic, readwrite) NSURLSessionDownloadTask *task;

@end

@implementation SKYDownloadAssetOperation

- (instancetype)initWithAsset:(SKYAsset *)asset
{
    self = [super init];
    if (self) {
        _asset = asset;
    }
    return self;
}

+ (instancetype)operationWithAsset:(SKYAsset *)asset
{
    return [[self alloc] initWithAsset:asset];
}

#pragma mark - NSOperation

- (BOOL)shouldObserveProgress
{
    return self.downloadAssetProgressBlock != nil;
}

- (NSURLRequest *)makeURLRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.asset.url];
    return request;
}

- (NSURLSessionTask *)makeURLSessionTaskWithSession:(NSURLSession *)session
                                            request:(NSURLRequest *)request
{
    NSURLSessionDownloadTask *task;
    task = [session
        downloadTaskWithRequest:request
              completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                  if ([self shouldObserveProgress]) {
                      [self.task
                          removeObserver:self
                              forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived))
                                 context:nil];
                  }

                  NSData *data = nil;
                  if (!error) {
                      data = [NSData dataWithContentsOfURL:location
                                                   options:NSDataReadingMappedIfSafe
                                                     error:&error];
                  }

                  [self handleRequestCompletionWithData:data response:response error:error];
              }];

    if ([self shouldObserveProgress]) {
        [task addObserver:self
               forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived))
                  options:0
                  context:nil];
    }

    self.task = task;
    return task;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([object isKindOfClass:[NSURLSessionDownloadTask class]]) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesReceived))]) {
            NSURLSessionDownloadTask *task = object;

            if (task.countOfBytesExpectedToReceive != NSURLSessionTransferSizeUnknown) {
                self.downloadAssetProgressBlock(self.asset,
                                                task.countOfBytesReceived * 1.0 /
                                                    task.countOfBytesExpectedToReceive);
            }
        }
    }
}

#pragma mark - Other methods

- (void)handleResponseWithData:(NSData *)data
{
    if (self.downloadAssetCompletionBlock) {
        self.downloadAssetCompletionBlock(_asset, data, nil);
    }
}

- (void)handleRequestError:(NSError *)error
{
    if (self.downloadAssetCompletionBlock) {
        self.downloadAssetCompletionBlock(_asset, nil, error);
    }
}

@end
