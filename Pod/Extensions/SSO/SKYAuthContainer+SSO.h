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

/**
 Login user with given provider by access token.
*/
- (void)loginOAuthProvider:(NSString *)providerID
               accessToken:(NSString *)accessToken
         completionHandler:(SKYContainerUserOperationActionCompletion _Nullable)completionHandler;

/**
 Link user with given provider by access token.
 */
- (void)linkOAuthProvider:(NSString *)providerID
              accessToken:(NSString *)accessToken
        completionHandler:(void (^_Nullable)(NSError *_Nullable))completionHandler;

/**
 Unlink given provider.
 */
- (void)unlinkOAuthProvider:(NSString *)providerID
          completionHandler:(void (^_Nullable)(NSError *_Nullable))completionHandler;

/**
 Get oauth provider user profiles, the result dictionary key is provider id and value is profile
 dictionary.
*/
- (void)getOAuthProviderProfilesWithCompletionHandler:
    (void (^_Nullable)(NSDictionary *_Nullable, NSError *_Nullable))completionHandler;

/**
 Login the user with a custom token.

 The custom token is typically created on an external server hosting a user database. This
 server generates the custom token so that the user on an external server can log in to
 Skygear Server.
 */
- (void)loginWithCustomToken:(NSString *)customToken
           completionHandler:(SKYContainerUserOperationActionCompletion _Nullable)completionHandler;

@end

NS_ASSUME_NONNULL_END
