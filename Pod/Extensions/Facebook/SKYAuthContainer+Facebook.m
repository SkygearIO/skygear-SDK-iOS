//
//  SKYContainer+Facebook.m
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

#import "SKYAuthContainer+Facebook.h"
#import "SKYAuthContainer_Private.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation SKYAuthContainer (Facebook)

- (void)loginWithFacebookAccessToken:(FBSDKAccessToken *)accessToken
                   completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    SKYLoginUserOperation *operation =
        [SKYLoginUserOperation operationWithProvider:@"com.facebook"
                                    providerAuthData:@{@"access_token" : accessToken.tokenString}];
    operation.authResponseDelegate = self;
    operation.loginCompletionBlock =
        ^(SKYRecord *user, SKYAccessToken *accessToken, NSError *error) {
            if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(user, error);
                });
            }
        };
    [self.container addOperation:operation];
}

@end
