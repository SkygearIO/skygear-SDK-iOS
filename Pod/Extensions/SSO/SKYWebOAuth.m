//
//  SKYWebOAuth.m
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

#import "SKYWebOAuth.h"
#import <SafariServices/SafariServices.h>

@implementation SKYWebOAuth {
    BOOL _inProgress;
    NSURL *_callbackURL;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
    SFAuthenticationSession *_authVC;
#pragma clang diagnostic pop
    SKYWebOAuthCompletion _oauthCompletionHandler;
}

- (void)startOAuthFlow:(NSString *_Nonnull)url
           callbackURL:(NSURL *_Nonnull)callbackURL
     completionHandler:(SKYWebOAuthCompletion _Nullable)completionHandler
{
    if (_inProgress) {
        return;
    }
    NSURL *requestURL = [NSURL URLWithString:url];

    _callbackURL = callbackURL;
    _oauthCompletionHandler = completionHandler;

    if (@available(iOS 11.0, *)) {
        _inProgress = YES;
        SFAuthenticationSession *authenticationVC = [[SFAuthenticationSession alloc]
                  initWithURL:requestURL
            callbackURLScheme:callbackURL.scheme
            completionHandler:^(NSURL *_Nullable callbackURL, NSError *_Nullable error) {
                if (callbackURL) {
                    [self resumeAuthorizationFlowWithURL:callbackURL];
                } else {
                    _oauthCompletionHandler(nil, error);
                    [self didCompleteOAuthFlow];
                }
            }];
        _authVC = authenticationVC;
        [authenticationVC start];
    }
}

- (void)didCompleteOAuthFlow
{
    _inProgress = NO;
    _callbackURL = nil;
    _authVC = nil;
    _oauthCompletionHandler = nil;
}

- (BOOL)resumeAuthorizationFlowWithURL:(NSURL *)url
{
    if (_oauthCompletionHandler == nil || _callbackURL == nil) {
        return false;
    }

    if (![_callbackURL.scheme isEqualToString:url.scheme] ||
        ![_callbackURL.host isEqualToString:url.host] ||
        ![_callbackURL.path isEqualToString:url.path]) {
        return false;
    }

    NSDictionary *result = nil;
    NSError *error = nil;
    NSURLComponents *components =
        [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSArray<NSURLQueryItem *> *queryItems = components.queryItems;
    for (NSURLQueryItem *queryItem in queryItems) {
        if ([queryItem.name isEqualToString:@"result"]) {
            NSString *json =
                [queryItem.value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            json = [json stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
            result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            break;
        }
    }

    if (result && result[@"result"]) {
        _oauthCompletionHandler(result, nil);
    } else if (result && result[@"error"]) {
        _oauthCompletionHandler(nil, result[@"error"]);
    } else {
        _oauthCompletionHandler(nil, error);
    }
    [self didCompleteOAuthFlow];
    return true;
}
@end
