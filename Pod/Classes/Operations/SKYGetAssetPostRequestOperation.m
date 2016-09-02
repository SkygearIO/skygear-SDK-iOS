//
//  SKYGetAssetPostRequestOperation.m
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

#import "SKYGetAssetPostRequestOperation.h"
#import "SKYAsset_Private.h"

@implementation SKYGetAssetPostRequestOperation

+ (instancetype)operationWithAsset:(SKYAsset *)asset
{
    return [[SKYGetAssetPostRequestOperation alloc] initWithAsset:asset];
}

- (instancetype)initWithAsset:(SKYAsset *)asset
{
    self = [super init];
    if (self) {
        [self setAsset:asset];
    }
    return self;
}

- (void)prepareForRequest
{
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] initWithDictionary:@{
        @"filename" : self.asset.name
    }];

    if (self.asset.mimeType.length > 0) {
        [payload setObject:self.asset.mimeType forKey:@"content-type"];
    }

    if (self.asset.fileSize) {
        [payload setObject:self.asset.fileSize forKey:@"content-size"];
    }

    [self setRequest:[[SKYRequest alloc] initWithAction:@"asset:put" payload:payload]];

    [self.request setAPIKey:self.container.APIKey];
    [self.request setAccessToken:self.container.currentAccessToken];
}

- (void)handleRequestError:(NSError *)error
{
    if (self.getAssetPostRequestCompletionBlock) {
        self.getAssetPostRequestCompletionBlock(nil, nil, nil, error);
    }
}

- (void)handleResponse:(SKYResponse *)response
{
    NSDictionary *result = response.responseDictionary[@"result"];

    [self.asset setName:result[@"asset"][@"$name"]];

    NSDictionary *rawPostRequest = result[@"post-request"];
    NSDictionary *extraFields = rawPostRequest[@"extra-fields"];
    NSURL *postURL = [NSURL URLWithString:rawPostRequest[@"action"]];

    if (postURL.scheme == nil) {
        postURL = [NSURL URLWithString:rawPostRequest[@"action"]
                         relativeToURL:self.container.endPointAddress];
    }

    if (self.getAssetPostRequestCompletionBlock) {
        self.getAssetPostRequestCompletionBlock(self.asset, postURL, extraFields, nil);
    }
}

@end
