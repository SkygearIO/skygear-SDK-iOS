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

typedef enum : NSInteger { SKYOAuthActionLogin, SKYOAuthActionLink } SKYOAuthActionType;

@implementation SKYAuthContainer (SSO)

- (void)loginOAuthProvider:(NSString *)providerID
                   options:(NSDictionary *)options
         completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    [self _oauthFlowWithProvider:providerID
                         options:options
                          action:SKYOAuthActionLogin
               completionHandler:completionHandler];
}

- (void)_oauthFlowWithProvider:(NSString *)providerID
                       options:(NSDictionary *)options
                        action:(SKYOAuthActionType)action
             completionHandler:(SKYContainerUserOperationActionCompletion)completionHandler
{
    NSDictionary *params = [self _genAuthURLParams:options];
    NSString *urlFormat = [self _getAuthURLWithAction:action];
    [[self container] callLambda:[NSString stringWithFormat:urlFormat, providerID]
             dictionaryArguments:params
               completionHandler:^(NSDictionary *result, NSError *error) {
                   if (error != nil) {
                       completionHandler(nil, error);
                       return;
                   }
                   NSLog(result[@"auth_url"]);
               }];
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

- (NSMutableDictionary *)_genAuthURLParams:(NSDictionary *)params
{
    NSMutableDictionary *newParams = [NSMutableDictionary dictionary];
    newParams[@"ux_mode"] = @"ios";

    NSString *host = self.container.endPointAddress.host;
    newParams[@"callback_url"] =
        [[NSURL alloc] initWithScheme:params[@"scheme"] host:host path:@"/auth_handler"]
            .absoluteString;

    if (params[@"scope"] != nil) {
        newParams[@"scope"] = params[@"scope"];
    }

    if (params[@"options"]) {
        newParams[@"options"] = params[@"options"];
    }
    return newParams;
}

@end
