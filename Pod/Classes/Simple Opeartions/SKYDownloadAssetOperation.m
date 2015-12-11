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
#import "SKYOperation+OverrideLifeCycle.h"

@interface SKYDownloadAssetOperation ()

@property (nonatomic, readwrite) SKYAsset *asset;
@property (nonatomic, readwrite) NSURLSession *session;
@property (nonatomic, readwrite) NSURLSessionDownloadTask *task;

@end

@implementation SKYDownloadAssetOperation

- (instancetype)initWithAsset:(SKYAsset *)asset
{
    self = [super init];
    if (self) {
        _session = [NSURLSession
            sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _asset = asset;
    }
    return self;
}

+ (instancetype)operationWithAsset:(SKYAsset *)asset
{
    return [[self alloc] initWithAsset:asset];
}

#pragma mark - NSOperation

- (void)start
{
    if (self.cancelled || self.executing || self.finished) {
        return;
    }

    [self operationWillStart];

    [self setExecuting:YES];

    BOOL shouldObserveProgress = self.downloadAssetProgressBlock != nil;

    NSURLRequest *request = [self makeRequest];
    __weak typeof(self) weakSelf = self;
    self.task = [self.session
        downloadTaskWithRequest:request
              completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                  __strong typeof(self) strongSelf = weakSelf;

                  [strongSelf handleCompletionWithLocation:location response:response error:error];

                  if (shouldObserveProgress) {
                      [strongSelf.task
                          removeObserver:self
                              forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived))
                                 context:nil];
                  }

                  [strongSelf setExecuting:NO];
                  [strongSelf setFinished:YES];

              }];

    if (shouldObserveProgress) {
        [self.task addObserver:self
                    forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived))
                       options:0
                       context:nil];
    }

    [self.task resume];
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
                self.downloadAssetProgressBlock(self.asset, task.countOfBytesReceived * 1.0 /
                                                                task.countOfBytesExpectedToReceive);
            }
        }
    }
}

#pragma mark - Other methods

- (NSURLRequest *)makeRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.asset.url];
    return request;
}

- (void)handleCompletionWithLocation:(NSURL *)location
                            response:(NSURLResponse *)response
                               error:(NSError *)error
{
    if (self.downloadAssetCompletionBlock) {
        NSData *data = nil;
        if (!error) {
            data = [NSData dataWithContentsOfURL:location
                                         options:NSDataReadingMappedIfSafe
                                           error:&error];
        }
        self.downloadAssetCompletionBlock(_asset, data, error);
    }
}

@end
