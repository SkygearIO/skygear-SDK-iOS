//
//  SKYAuthContainer+SSO.m
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

#import "SKYAuthContainer+SSO.h"
#import "SKYAuthContainer_Private.h"
#import "SKYLoginCustomTokenOperation.h"
#import "SKYWebOAuth.h"

typedef enum : NSInteger { SKYOAuthActionLogin, SKYOAuthActionLink } SKYOAuthActionType;

@implementation SKYAuthContainer (SSO)

#pragma mark - OAuth

- (void)loginOAuthProvider:(NSString *)providerID
                   options:(NSDictionary *)options
         completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    __weak typeof(self) weakSelf = self;
    [self sso_oauthFlowWithProvider:providerID
                            options:options
                             action:SKYOAuthActionLogin
                  completionHandler:^(NSDictionary *result, NSError *error) {
                      [weakSelf sso_handleLoginOAuthResult:result
                                                     error:error
                                         completionHandler:completionHandler];
                  }];
}

- (void)linkOAuthProvider:(NSString *)providerID
                  options:(NSDictionary *)options
        completionHandler:(void (^)(NSError *))completionHandler
{
    [self sso_oauthFlowWithProvider:providerID
                            options:options
                             action:SKYOAuthActionLink
                  completionHandler:^(NSDictionary *result, NSError *error) {
                      if (completionHandler) {
                          completionHandler(error);
                      }
                  }];
}

- (BOOL)resumeOAuthFlow:(NSURL *)url
                options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    return [[SKYWebOAuth shared] resumeAuthorizationFlowWithURL:url];
}

- (void)sso_oauthFlowWithProvider:(NSString *)providerID
                          options:(NSDictionary *)options
                           action:(SKYOAuthActionType)action
                completionHandler:(SKYWebOAuthCompletion)completionHandler
{
    NSError *validateError = [self sso_validateGetAuthURLParams:options];
    if (validateError) {
        if (completionHandler) {
            completionHandler(nil, validateError);
        }
        return;
    }
    NSDictionary *params = [self sso_genAuthURLParams:options];
    NSURL *callbackURL = [self sso_genCallbackURL:options[@"scheme"]];

    [[self container] callLambda:[self sso_getAuthURLWithAction:action provider:providerID]
             dictionaryArguments:params
               completionHandler:^(NSDictionary *result, NSError *error) {
                   if (error != nil) {
                       if (completionHandler) {
                           completionHandler(nil, error);
                       }
                       return;
                   }
                   [[SKYWebOAuth shared] startOAuthFlow:result[@"auth_url"]
                                            callbackURL:callbackURL
                                      completionHandler:completionHandler];
               }];
}

- (void)sso_handleLoginOAuthResult:(NSDictionary *)result
                             error:(NSError *)error
                 completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    NSError *loginError = error;
    SKYRecord *user = nil;
    SKYAccessToken *accessToken = nil;
    if (!loginError) {
        NSDictionary *response = result[@"result"];
        NSDictionary *profile = response[@"profile"];
        NSString *recordID = profile[@"_id"];
        if ([recordID hasPrefix:@"user/"] && response[@"access_token"]) {
            user = [[SKYRecordDeserializer deserializer] recordWithDictionary:profile];
            accessToken = [[SKYAccessToken alloc] initWithTokenString:response[@"access_token"]];

            [self updateWithUser:user accessToken:accessToken];
        } else {
            loginError = [[[SKYErrorCreator alloc] init]
                errorWithCode:SKYErrorBadResponse
                      message:@"Returned data does not contain expected data."];
        }
    }
    if (completionHandler) {
        completionHandler(user, loginError);
    }
}

- (NSString *)sso_getAuthURLWithAction:(SKYOAuthActionType)action provider:(NSString *)provider
{
    switch (action) {
        case SKYOAuthActionLogin:
            return [NSString stringWithFormat:@"sso/%@/login_auth_url", provider];
        case SKYOAuthActionLink:
            return [NSString stringWithFormat:@"sso/%@/link_auth_url", provider];
        default:
            return nil;
    }
}

- (NSError *)sso_validateGetAuthURLParams:(NSDictionary *)params
{
    if (!params[@"scheme"]) {
        return [[[SKYErrorCreator alloc] init] errorWithCode:SKYErrorInvalidData
                                                     message:@"Scheme is required"];
    }

    return nil;
}

- (NSDictionary *)sso_genAuthURLParams:(NSDictionary *)params
{
    NSMutableDictionary *newParams = [NSMutableDictionary dictionary];
    newParams[@"ux_mode"] = @"ios";

    newParams[@"callback_url"] = [self sso_genCallbackURL:params[@"scheme"]].absoluteString;

    if (params[@"scope"] != nil) {
        newParams[@"scope"] = params[@"scope"];
    }

    if (params[@"options"]) {
        newParams[@"options"] = params[@"options"];
    }
    return [NSDictionary dictionaryWithDictionary:newParams];
}

- (NSURL *)sso_genCallbackURL:(NSString *)scheme
{
    NSString *host = self.container.endPointAddress.host;
    return [[NSURL alloc] initWithScheme:scheme host:host path:@"/auth_handler"];
}

#pragma mark - Custom Token

- (void)loginWithCustomToken:(NSString *)customToken
           completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    SKYLoginCustomTokenOperation *op =
        [SKYLoginCustomTokenOperation operationWithCustomToken:customToken];
    op.loginCompletionBlock = ^(SKYRecord *user, SKYAccessToken *accessToken, NSError *error) {
        if (!error) {
            [self.container.auth updateWithUser:user accessToken:accessToken];
        }

        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(user, error);
            });
        }
    };
    [self.container addOperation:op];
}

@end
