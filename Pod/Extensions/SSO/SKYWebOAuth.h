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

typedef void (^SKYWebOAuthCompletion)(NSDictionary *_Nullable result, NSError *_Nullable error);

@interface SKYWebOAuth : NSObject

+ (instancetype _Nonnull)shared;
- (void)startOAuthFlow:(NSString *_Nonnull)url
           callbackURL:(NSURL *_Nonnull)callbackURL
     completionHandler:(SKYWebOAuthCompletion _Nullable)completionHandler;
- (BOOL)resumeAuthorizationFlowWithURL:(NSURL *_Nonnull)url;

@end
