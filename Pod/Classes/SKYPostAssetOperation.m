//
//  SKYPostAssetOperation.m
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

#import "SKYPostAssetOperation.h"
#import "NSURLRequest+SKYRequest.h"
#import "SKYAsset_Private.h"
#import "SKYOperationSubclass.h"

@interface SKYOperation ()

@property (nonatomic, readwrite) BOOL executing;
@property (nonatomic, readwrite) BOOL finished;

- (void)didEncounterError:(NSError *)error;

@end

@interface SKYPostAssetOperation ()

@property (nonatomic, readwrite) SKYAsset *asset;
@property (nonatomic, readwrite) NSURL *url;
@property (nonatomic, readwrite) NSDictionary *extraFields;

@property (nonatomic, readwrite) NSURLSessionUploadTask *task;

@property (nonatomic, readonly) NSData *postData;
@property (nonatomic, readonly) NSString *multipartBoundary;
@property (nonatomic, readonly, getter=shouldObserveProgress) BOOL shouldObserveProgress;

@end

@implementation SKYPostAssetOperation

@synthesize postData = _postData;
@synthesize multipartBoundary = _multipartBoundary;

+ (instancetype)operationWithAsset:(SKYAsset *_Nonnull)asset url:(NSURL *_Nonnull)url
{
    return [SKYPostAssetOperation operationWithAsset:asset url:url extraFields:nil];
}

+ (instancetype)operationWithAsset:(SKYAsset *_Nonnull)asset
                               url:(NSURL *_Nonnull)url
                       extraFields:(NSDictionary *_Nullable)extraFields
{
    return [[SKYPostAssetOperation alloc] initWithAsset:asset url:url extraFields:extraFields];
}

- (instancetype)initWithAsset:(SKYAsset *_Nonnull)asset
                          url:(NSURL *_Nonnull)url
                  extraFields:(NSDictionary *_Nullable)extraFields
{
    self = [super init];
    if (self) {
        [self setAsset:asset];
        [self setUrl:url];
        [self setExtraFields:extraFields];
    }

    return self;
}

#pragma mark - getter
- (NSData *)postData
{
    if (!_postData) {
        NSMutableData *httpData = [[NSMutableData alloc] init];
        NSString *boundary = self.multipartBoundary;

        // append data for form fields
        if (self.extraFields) {
            [self.extraFields enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSObject *value,
                                                                  BOOL *stop) {
                [httpData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]
                                         dataUsingEncoding:NSUTF8StringEncoding]];
                [httpData appendData:[[NSString
                                         stringWithFormat:
                                             @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",
                                             key] dataUsingEncoding:NSUTF8StringEncoding]];
                [httpData appendData:[[NSString stringWithFormat:@"%@\r\n", value]
                                         dataUsingEncoding:NSUTF8StringEncoding]];
            }];
        }

        // append data for file
        NSData *fileData = [NSData dataWithContentsOfURL:self.asset.url];

        [httpData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]
                                 dataUsingEncoding:NSUTF8StringEncoding]];
        [httpData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; "
                                                         @"name=\"file\"; filename=\"%@\"\r\n",
                                                         self.asset.name]
                                 dataUsingEncoding:NSUTF8StringEncoding]];
        [httpData
            appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", self.asset.mimeType]
                           dataUsingEncoding:NSUTF8StringEncoding]];
        [httpData appendData:fileData];
        [httpData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

        [httpData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary]
                                 dataUsingEncoding:NSUTF8StringEncoding]];

        _postData = httpData;
    }

    return _postData;
}

- (BOOL)shouldObserveProgress
{
    return self.postAssetProgressBlock != nil;
}

- (NSString *)multipartBoundary
{
    if (!_multipartBoundary) {
        _multipartBoundary = [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
    }

    return _multipartBoundary;
}

#pragma mark - override methods
- (NSURLRequest *)makeURLRequest
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.url];
    [request setHTTPMethod:@"POST"];

    NSString *multipartContentType =
        [NSString stringWithFormat:@"multipart/form-data; boundary=%@", self.multipartBoundary];

    [request setValue:multipartContentType forHTTPHeaderField:@"Content-Type"];

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

- (NSURLSessionTask *)makeURLSessionTaskWithSession:(NSURLSession *)session
                                            request:(NSURLRequest *)request
{
    [self setTask:[session uploadTaskWithRequest:request
                                        fromData:self.postData
                               completionHandler:^(NSData *_Nullable data,
                                                   NSURLResponse *_Nullable response,
                                                   NSError *_Nullable error) {
                                   if (self.shouldObserveProgress) {
                                       [self.task removeObserver:self
                                                      forKeyPath:NSStringFromSelector(
                                                                     @selector(countOfBytesSent))];
                                   }

                                   [self handleRequestCompletionWithData:data
                                                                response:response
                                                                   error:error];
                               }]];

    if (self.shouldObserveProgress) {
        [self.task addObserver:self
                    forKeyPath:NSStringFromSelector(@selector(countOfBytesSent))
                       options:0
                       context:nil];
    }

    return self.task;
}

- (void)handleRequestCompletionWithData:(NSData *)data
                               response:(NSURLResponse *)response
                                  error:(NSError *)requestError
{
    if (requestError) {
        NSError *error = [self.errorCreator errorWithCode:SKYErrorNetworkFailure
                                                 userInfo:@{NSUnderlyingErrorKey : requestError}];

        [self didEncounterError:error];
        [self setFinished:YES];

        return;
    }

    // directly call completion block instead of -handleResponseWithData: method
    // since some asset backing store (i.e. cloud asset) does not return any data
    // when the request succeed.
    NSAssert([response isKindOfClass:[NSHTTPURLResponse class]],
             @"Returned response is not NSHTTPURLResponse");
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

    NSError *operationError;
    if (httpResponse.statusCode >= 400) {
        NSLog(@"Asset Post Request Fails: %@",
              [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        operationError = [self.errorCreator errorWithCode:SKYErrorUnknownError
                                                  message:@"Asset Post Request Fails"];
    }

    if (self.postAssetCompletionBlock) {
        self.postAssetCompletionBlock(self.asset, operationError);
    }

    [self setFinished:YES];
}

#pragma mark - KVO
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
            self.postAssetProgressBlock(
                self.asset, task.countOfBytesSent * 1.0 / self.asset.fileSize.integerValue);
        }
    }
}

@end
