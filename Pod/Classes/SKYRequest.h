//
//  SKYRequest.h
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

#import "SKYAccessToken.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Undocumented
@interface SKYRequest : NSObject

/// Undocumented
@property (nonatomic, copy) NSString *action;
/// Undocumented
@property (nonatomic, copy) NSDictionary *_Nullable payload;
/// Undocumented
@property (nonatomic, strong) SKYAccessToken *accessToken;

/**
 Sets or returns the API key to be associated with the request.
 */
@property (nonatomic, strong) NSString *APIKey;
/// Undocumented
@property (nonatomic, strong) NSURL *baseURL;
/// Undocumented
@property (nonatomic, readonly) NSString *requestPath;

/// Undocumented
- (instancetype)initWithAction:(NSString *)action payload:(NSDictionary *_Nullable)payload;

@end

NS_ASSUME_NONNULL_END
