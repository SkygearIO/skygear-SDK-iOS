//
//  SKYRequest.h
//  SkyKit
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

#import <Foundation/Foundation.h>
#import "SKYAccessToken.h"

@interface SKYRequest : NSObject

@property (nonatomic, copy) NSString *action;
@property (nonatomic, copy) NSDictionary *payload;
@property (nonatomic, strong) SKYAccessToken *accessToken;

/**
 Sets or returns the API key to be associated with the request.
 */
@property (nonatomic, strong) NSString *APIKey;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, readonly) NSString *requestPath;

- (instancetype)initWithAction:(NSString *)action payload:(NSDictionary *)payload;

@end
