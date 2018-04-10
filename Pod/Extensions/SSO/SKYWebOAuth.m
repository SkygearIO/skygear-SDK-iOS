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
    SKYErrorCreator *_errorCreator;
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

- (instancetype)init
{
    if ((self = [super init])) {
        _errorCreator = [[SKYErrorCreator alloc] init];
    }
    return self;
}

- (void)startOAuthFlow:(NSString *)url
           callbackURL:(NSURL *)callbackURL
     completionHandler:(SKYWebOAuthCompletion)completionHandler
{
    if (_inProgress) {
        return;
    }
    NSURL *requestURL = [NSURL URLWithString:url];

    _callbackURL = callbackURL;
    _oauthCompletionHandler = completionHandler;
    SKYErrorCreator *errorCreator = _errorCreator;

    if (@available(iOS 11.0, *)) {
        _inProgress = YES;
        SFAuthenticationSession *authenticationVC = [[SFAuthenticationSession alloc]
                  initWithURL:requestURL
            callbackURLScheme:callbackURL.scheme
            completionHandler:^(NSURL *callbackURL, NSError *error) {
                if (callbackURL) {
                    [self resumeAuthorizationFlowWithURL:callbackURL];
                } else {
                    if (completionHandler) {
                        completionHandler(nil,
                                          [errorCreator errorWithCode:SKYErrorNotAuthenticated
                                                              message:@"User cancel oauth flow"]);
                    }
                    [self didCompleteOAuthFlow];
                }
            }];
        _authVC = authenticationVC;
        [authenticationVC start];
    } else if (@available(iOS 9.0, *)) {
        _safariVC =
            [[SFSafariViewController alloc] initWithURL:requestURL entersReaderIfAvailable:NO];
        _safariVC.delegate = self;
        _topVC = [self findTopViewController];
        [_topVC presentViewController:_safariVC animated:YES completion:nil];
    } else {
        if (completionHandler) {
            completionHandler(nil, [_errorCreator errorWithCode:SKYErrorUnknownError
                                                        message:@"Only support iOS 9 or above"]);
        }
        [self didCompleteOAuthFlow];
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
    if (_callbackURL == nil) {
        return false;
    }

    if (![_callbackURL.scheme isEqualToString:url.scheme] ||
        ![_callbackURL.host isEqualToString:url.host] ||
        ![_callbackURL.path isEqualToString:url.path]) {
        return false;
    }

    // parse the result only if there is _oauthCompletionHandler
    if (_oauthCompletionHandler) {
        NSDictionary *result = nil;
        NSError *error = nil;
        NSURLComponents *components =
            [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
        NSArray<NSURLQueryItem *> *queryItems = components.queryItems;
        for (NSURLQueryItem *queryItem in queryItems) {
            if ([queryItem.name isEqualToString:@"result"]) {
                NSString *encodedJSON = [queryItem.value
                    stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                encodedJSON =
                    [encodedJSON stringByReplacingOccurrencesOfString:@"+" withString:@" "];
                NSData *decodedData =
                    [[NSData alloc] initWithBase64EncodedString:encodedJSON options:0];
                NSString *json =
                    [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];

                NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
                result =
                    [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                break;
            }
        }

        if (result && result[@"result"]) {
            _oauthCompletionHandler(result, nil);
        } else if (result && result[@"error"]) {
            _oauthCompletionHandler(nil,
                                    [_errorCreator errorWithResponseDictionary:result[@"error"]]);
        } else {
            NSError *error =
                [_errorCreator errorWithCode:SKYErrorUnknownError
                                    userInfo:@{
                                        SKYErrorMessageKey : @"Fail to parse callback url",
                                        @"callbackURL" : url.absoluteString
                                    }];
            _oauthCompletionHandler(nil, error);
        }
    }

    // reset after completing oauth flow
    if (@available(iOS 11.0, *)) {
        [_authVC cancel];
    } else if (@available(iOS 9.0, *)) {
        [_topVC dismissViewControllerAnimated:YES completion:nil];
    }

    [self didCompleteOAuthFlow];
    return true;
}

- (UIViewController *)findTopViewController
{
    UIViewController *vc = UIApplication.sharedApplication.keyWindow.rootViewController;
    return [self findTopViewController:vc];
}

- (UIViewController *)findTopViewController:(UIViewController *)viewController
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
    return [self findTopViewController:nextVC];
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
    if (_oauthCompletionHandler) {
        _oauthCompletionHandler(nil, [_errorCreator errorWithCode:SKYErrorNotAuthenticated
                                                          message:@"User cancel oauth flow"]);
    }
    [self didCompleteOAuthFlow];
}

@end
