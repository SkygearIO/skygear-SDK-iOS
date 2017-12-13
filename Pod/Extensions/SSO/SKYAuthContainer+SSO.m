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
#import "SKYWebOAuth.h"

typedef enum : NSInteger { SKYOAuthActionLogin, SKYOAuthActionLink } SKYOAuthActionType;

@implementation SKYAuthContainer (SSO)

- (void)loginOAuthProvider:(NSString *)providerID
                   options:(NSDictionary *)options
         completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    __weak typeof(self) weakSelf = self;
    [self _oauthFlowWithProvider:providerID
                         options:options
                          action:SKYOAuthActionLogin
               completionHandler:^(NSDictionary *_Nullable result, NSError *_Nullable error) {
                   [weakSelf _handleLoginOAuthResult:result
                                               error:error
                                   completionHandler:completionHandler];
               }];
}

- (void)linkOAuthProvider:(NSString *)providerID
                  options:(NSDictionary *)options
        completionHandler:(void (^_Nullable)(NSError *_Nullable))completionHandler
{
    [self _oauthFlowWithProvider:providerID
                         options:options
                          action:SKYOAuthActionLink
               completionHandler:^(NSDictionary *_Nullable result, NSError *_Nullable error) {
                   completionHandler(error);
               }];
}

- (void)_oauthFlowWithProvider:(NSString *)providerID
                       options:(NSDictionary *)options
                        action:(SKYOAuthActionType)action
             completionHandler:(SKYWebOAuthCompletion)completionHandler
{
    NSError *validateError = [self _validateGetAuthURLParams:options];
    if (validateError) {
        completionHandler(nil, validateError);
        return;
    }
    NSDictionary *params = [self _genAuthURLParams:options];
    NSString *urlFormat = [self _getAuthURLWithAction:action];
    NSURL *callbackURL = [self _genCallbackURL:options[@"scheme"]];

    [[self container] callLambda:[NSString stringWithFormat:urlFormat, providerID]
             dictionaryArguments:params
               completionHandler:^(NSDictionary *result, NSError *error) {
                   if (error != nil) {
                       completionHandler(nil, error);
                       return;
                   }
                   [[SKYWebOAuth shared] startOAuthFlow:result[@"auth_url"]
                                            callbackURL:callbackURL
                                      completionHandler:completionHandler];
               }];
}

- (void)_handleLoginOAuthResult:(NSDictionary *)result
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
            // register device when login and signup success
            [self.container.push registerDeviceCompletionHandler:nil];
        } else {
            loginError = [[[SKYErrorCreator alloc] init]
                errorWithCode:SKYErrorBadResponse
                      message:@"Returned data does not contain expected data."];
        }
    }
    completionHandler(user, loginError);
}

- (NSString *)_getAuthURLWithAction:(SKYOAuthActionType)action
{
    switch (action) {
        case SKYOAuthActionLogin:
            return @"sso/%@/login_auth_url";
            break;
        case SKYOAuthActionLink:
            return @"sso/%@/link_auth_url";
        default:
            return nil;
            break;
    }
}

- (NSError *)_validateGetAuthURLParams:(NSDictionary *)params
{
    if (!params[@"scheme"]) {
        return [[[SKYErrorCreator alloc] init] errorWithCode:SKYErrorInvalidData
                                                     message:@"Scheme is required"];
    }

    return nil;
}

- (NSDictionary *)_genAuthURLParams:(NSDictionary *)params
{
    NSMutableDictionary *newParams = [NSMutableDictionary dictionary];
    newParams[@"ux_mode"] = @"ios";

    newParams[@"callback_url"] = [self _genCallbackURL:params[@"scheme"]].absoluteString;

    if (params[@"scope"] != nil) {
        newParams[@"scope"] = params[@"scope"];
    }

    if (params[@"options"]) {
        newParams[@"options"] = params[@"options"];
    }
    return [NSDictionary dictionaryWithDictionary:newParams];
}

- (NSURL *)_genCallbackURL:(NSString *)scheme
{
    NSString *host = self.container.endPointAddress.host;
    return [[NSURL alloc] initWithScheme:scheme host:host path:@"/auth_handler"];
}

- (BOOL)resumeOAuthFlow:(NSURL *)url
                options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    return [[SKYWebOAuth shared] resumeAuthorizationFlowWithURL:url];
}

@end
