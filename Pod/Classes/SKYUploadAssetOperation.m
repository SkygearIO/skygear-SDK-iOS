//
//  SKYUploadAssetOperation.m
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

#import "SKYUploadAssetOperation.h"
#import "SKYOperationSubclass.h"

#import "NSURLRequest+SKYRequest.h"
#import "SKYAsset_Private.h"
#import "SKYDataSerialization.h"

@interface SKYUploadAssetOperation ()

@property (nonatomic, readwrite) NSURLSessionUploadTask *task;

@end

@implementation SKYUploadAssetOperation

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
    return self.uploadAssetProgressBlock != nil;
}

- (NSURLSessionTask *)makeURLSessionTaskWithSession:(NSURLSession *)session
                                            request:(NSURLRequest *)request
{
    NSURLSessionUploadTask *task;
    task = [session
        uploadTaskWithRequest:request
                     fromFile:self.asset.url
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if ([self shouldObserveProgress]) {
                    [self.task removeObserver:self
                                   forKeyPath:NSStringFromSelector(@selector(countOfBytesSent))
                                      context:nil];
                }

                [self handleRequestCompletionWithData:data response:response error:error];
            }];

    if ([self shouldObserveProgress]) {
        [task addObserver:self
               forKeyPath:NSStringFromSelector(@selector(countOfBytesSent))
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
    if ([object isKindOfClass:[NSURLSessionUploadTask class]]) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesSent))]) {
            NSURLSessionUploadTask *task = object;

            // task.countOfBytesExpectedToSend sometimes returns zero for unknown reason
            // since we are saving asset data in file anyway, we access the value from asset
            // instead.
            self.uploadAssetProgressBlock(
                self.asset, task.countOfBytesSent * 1.0 / self.asset.fileSize.integerValue);
        }
    }
}

- (NSURLRequest *)makeURLRequest
{
    NSURL *baseURL = [NSURL URLWithString:@"files/" relativeToURL:self.container.endPointAddress];
    NSURL *url =
        [NSURL URLWithString:[self.asset.name stringByAddingPercentEncodingWithAllowedCharacters:
                                                  [NSCharacterSet URLPathAllowedCharacterSet]]
               relativeToURL:baseURL];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";

    NSString *mimeType = self.asset.mimeType;
    if ([mimeType length] > 0) {
        [request setValue:[mimeType lowercaseString] forHTTPHeaderField:@"Content-Type"];
    }

    // SKYKit-related headers
    NSString *apiKey = self.container.APIKey;
    if (apiKey.length) {
        [request setValue:self.container.APIKey forHTTPHeaderField:SKYRequestHeaderAPIKey];
    }
    NSString *accessTokenString = self.container.currentAccessToken.tokenString;
    if (accessTokenString) {
        [request setValue:accessTokenString forHTTPHeaderField:SKYRequestHeaderAccessTokenKey];
    }

    return request;
}

- (void)handleResponse:(SKYResponse *)response
{
    [super handleResponse:response];

    NSError *error = nil;
    NSDictionary *rawAsset = response.responseDictionary[@"result"];
    NSString *name = rawAsset[@"$name"];
    if (name.length) {
        _asset.name = name;
    } else {
        error = [self.errorCreator
            errorWithCode:SKYErrorInvalidData
                  message:@"Uploaded asset does not have a name associated with it."];

        return;
    }

    if (self.uploadAssetCompletionBlock) {
        self.uploadAssetCompletionBlock(_asset, error);
    }
}

- (void)handleRequestError:(NSError *)error
{
    if (self.uploadAssetCompletionBlock) {
        self.uploadAssetCompletionBlock(_asset, error);
    }
}

@end
