//
//  SKYAuthContainer+SSO.h
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
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKYAuthContainer (SSO)

/**
  Login user with given provider.
 */
- (void)loginOAuthProvider:(NSString *)providerID
                   options:(NSDictionary *)options
         completionHandler:(SKYContainerUserOperationActionCompletion _Nullable)completionHandler;

/**
 Link user with given provider.
 */
- (void)linkOAuthProvider:(NSString *)providerID
                  options:(NSDictionary *)options
        completionHandler:(void (^_Nullable)(NSError *_Nullable))completionHandler;

/**
  Resume current oauth flow with url, need to be called by application:openURL:options: in
  appDelegate
 */
- (BOOL)resumeOAuthFlow:(NSURL *)url
                options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *_Nullable)options;
@end

NS_ASSUME_NONNULL_END
