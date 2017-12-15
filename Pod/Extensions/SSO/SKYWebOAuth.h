//
//  SKYWebOAuth.h
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

#import <SKYKit/SKYKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SKYWebOAuthCompletion)(NSDictionary *_Nullable result, NSError *_Nullable error);

@interface SKYWebOAuth : NSObject

/// Undocumented
+ (instancetype)shared;

/**
 Use the url to open safari and start the web oauth throw
 */
- (void)startOAuthFlow:(NSString *)url
           callbackURL:(NSURL *)callbackURL
     completionHandler:(SKYWebOAuthCompletion _Nullable)completionHandler;

/// Undocumented
- (BOOL)resumeAuthorizationFlowWithURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
