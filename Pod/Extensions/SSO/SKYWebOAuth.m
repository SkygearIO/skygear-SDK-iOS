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

@interface SKYWebOAuth () <SFSafariViewControllerDelegate>
@end

@implementation SKYWebOAuth {
    BOOL _inProgress;
    NSURL *_callbackURL;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
    SFAuthenticationSession *_authVC;
#pragma clang diagnostic pop
    SFSafariViewController *_safariVC;
    UIViewController *_topVC;
    SKYWebOAuthCompletion _oauthCompletionHandler;
}

+ (instancetype)shared
{
    static SKYWebOAuth *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SKYWebOAuth alloc] init];
    });
    return sharedInstance;
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
    } else if (@available(iOS 9.0, *)) {
        _safariVC =
            [[SFSafariViewController alloc] initWithURL:requestURL entersReaderIfAvailable:NO];
        _safariVC.delegate = self;
        _topVC = [self _findTopViewController];
        [_topVC presentViewController:_safariVC animated:YES completion:nil];
    }
}

- (void)didCompleteOAuthFlow
{
    _inProgress = NO;
    _callbackURL = nil;
    _authVC = nil;
    _topVC = nil;
    _safariVC = nil;
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

    if (@available(iOS 11.0, *)) {
        [_authVC cancel];
    } else if (@available(iOS 9.0, *)) {
        [_topVC dismissViewControllerAnimated:YES completion:nil];
    }

    [self didCompleteOAuthFlow];
    return true;
}

- (UIViewController *)_findTopViewController
{
    UIViewController *vc = UIApplication.sharedApplication.keyWindow.rootViewController;
    return [self _findTopViewController:vc];
}

- (UIViewController *)_findTopViewController:(UIViewController *)viewController
{
    UIViewController *nextVC = nil;
    if (viewController.presentedViewController) {
        nextVC = viewController.presentedViewController;
    } else if ([viewController isKindOfClass:[UINavigationController class]]) {
        nextVC = ((UINavigationController *)viewController).topViewController;
    } else if ([viewController isKindOfClass:[UITabBarController class]]) {
        nextVC = ((UITabBarController *)viewController).selectedViewController;
    } else if ([viewController isKindOfClass:[UISplitViewController class]]) {
        nextVC = ((UISplitViewController *)viewController).viewControllers.lastObject;
    } else {
        return viewController;
    }
    return [self _findTopViewController:nextVC];
}

#pragma mark - SFSafariViewControllerDelegate

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller NS_AVAILABLE_IOS(9.0)
{
    if (controller != _safariVC) {
        return;
    }
    if (!_inProgress) {
        return;
    }
}

@end
