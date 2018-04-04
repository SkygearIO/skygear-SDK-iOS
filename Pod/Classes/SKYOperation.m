//
//  SKYOperation.m
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
//

#import "SKYOperation.h"
#import "NSError+SKYError.h"
#import "NSURLRequest+SKYRequest.h"
#import "SKYAuthContainer_Private.h"
#import "SKYDataSerialization.h"
#import "SKYError.h"
#import "SKYOperationSubclass.h"
#import "SKYOperation_Private.h"
#import "SKYResponse.h"

@implementation SKYOperation {
    BOOL _executing;
    BOOL _finished;
    NSError *_error;
    NSDictionary *_response;
}

+ (Class)responseClass
{
    return [SKYResponse class];
}

- (instancetype)init
{
    if ((self = [super init])) {
        _errorCreator = [[SKYErrorCreator alloc] init];
    }
    return self;
}

- (instancetype)initWithRequest:(SKYRequest *)request;
{
    if ((self = [self init])) {
        self.request = request;
    }
    return self;
}

- (BOOL)isAsynchronous
{
    return YES;
}

- (BOOL)isExecuting
{
    return self.asynchronous ? _executing : [super isExecuting];
}

- (void)setExecuting:(BOOL)aBOOL
{
    if (aBOOL != _executing) {
        [self willChangeValueForKey:@"isExecuting"];
        _executing = aBOOL;
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (BOOL)isFinished
{
    return self.asynchronous ? _finished : [super isFinished];
}

- (void)setFinished:(BOOL)aBOOL
{
    if (aBOOL != _finished) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = aBOOL;
        [self didChangeValueForKey:@"isFinished"];
    }
}

- (NSError *)error
{
    return _error;
}

- (NSError *)lastError
{
    return [_error copy];
}

- (NSDictionary *)response
{
    return [_response copy];
}

- (NSURLRequest *)makeURLRequestWithError:(NSError **)error
{
    // -makeURLRequest is a deprecated name of this selector.
    // If -makeURLRequest is implemented, call that method instead.
    // Should be removed if confirming no subclasses implement -makeURLRequest.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([self respondsToSelector:@selector(makeURLRequest)]) {
        return [self performSelector:@selector(makeURLRequest)];
    }
#pragma clang diagnostic pop

    if (!self.request) {
        [self prepareForRequest];
        NSError *containerConfigError = [self addContainerConfigurationToRequest:self.request];
        if (containerConfigError) {
            if (error) {
                *error = containerConfigError;
            }
            return nil;
        }
    }

    NSMutableURLRequest *request = [NSMutableURLRequest mutableRequestWithSKYRequest:self.request];
    request.timeoutInterval = self.timeoutInterval;

    NSString *version = [NSString stringWithFormat:@"skygear-SDK-iOS/%@", SKYVersion];
    [request setValue:version forHTTPHeaderField:@"X-Skygear-SDK-Version"];
    return [request copy];
}

- (NSError *)addContainerConfigurationToRequest:(SKYRequest *)request
{
    if (!self.container.endPointAddress) {
        return [_errorCreator
            errorWithCode:SKYErrorContainerNotConfigured
                 userInfo:@{SKYErrorMessageKey : @"Container endpoint is not configured."}];
    }
    request.baseURL = self.container.endPointAddress;

    if (self.requiresAPIKey) {
        if (!self.container.APIKey) {
            return [_errorCreator
                errorWithCode:SKYErrorContainerNotConfigured
                     userInfo:@{SKYErrorMessageKey : @"Container API Key is not configured."}];
        }
        request.APIKey = self.container.APIKey;
    }

    if (self.requiresAccessToken) {
        if (!self.container.auth.currentAccessToken) {
            return [_errorCreator
                errorWithCode:SKYErrorNotAuthenticated
                     userInfo:@{
                         SKYErrorMessageKey :
                             @"Request requires access token but none is available."
                     }];
        }
        request.accessToken = self.container.auth.currentAccessToken;
    }
    return nil;
}

- (NSURLSessionTask *)makeURLSessionTaskWithSession:(NSURLSession *)session
                                            request:(NSURLRequest *)request
{
    NSURLSessionTask *task;
    task = [session dataTaskWithRequest:request
                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                          [self handleRequestCompletionWithData:data response:response error:error];
                      }];
    return task;
}

- (void)prepareForRequest
{
    @throw [NSException
        exceptionWithName:NSInternalInconsistencyException
                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                                     NSStringFromSelector(_cmd)]
                 userInfo:nil];
}

- (void)operationWillStart
{
    if (![self container]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"The operation being started does not have a "
                                              @"SKYContainer set to the `container` property."
                                     userInfo:nil];
    }
}

- (void)start
{
    if (!self.asynchronous) {
        [super start];
        return;
    }

    if (self.cancelled || self.executing || self.finished) {
        return;
    }

    [self operationWillStart];

    [self setExecuting:YES];

    NSURLSessionConfiguration *myConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:myConfig];

    NSError *requestError;
    NSURLRequest *request = [self makeURLRequestWithError:&requestError];
    if (!request) {
        [self handleRequestCompletionWithData:nil response:nil error:requestError];
        return;
    }

    NSURLSessionTask *task = [self makeURLSessionTaskWithSession:session request:request];
    [task resume];
}

- (NSDictionary *)parseResponse:(NSData *)data error:(NSError **)error
{
    NSError *jsonError = nil;
    NSDictionary *responseDictionary =
        [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    if (jsonError) {
        if (error) {
            *error = [_errorCreator errorWithCode:SKYErrorBadResponse
                                         userInfo:@{
                                             SKYErrorMessageKey : @"Unable to parse JSON data.",
                                             NSUnderlyingErrorKey : jsonError
                                         }];
        }
        return nil;
    }

    if (![responseDictionary isKindOfClass:[NSDictionary class]]) {
        if (error) {
            *error =
                [_errorCreator errorWithCode:SKYErrorBadResponse
                                    userInfo:@{
                                        SKYErrorMessageKey : @"Response is not a JSON dictionary.",
                                    }];
        }
        return nil;
    }
    return responseDictionary;
}

- (NSError *)errorWithResponse:(NSHTTPURLResponse *)response data:(NSData *)data
{
    NSError *error = nil;
    NSDictionary *responseDictionary = [self parseResponse:data error:&error];
    if (error) {
        // Provide an error object by information in status code
        switch (response.statusCode) {
            case 413:
                return [_errorCreator errorWithCode:SKYErrorRequestPayloadTooLarge];
            case 503:
                return [_errorCreator errorWithCode:SKYErrorServiceUnavailable];
            default:
                return [_errorCreator errorWithCode:SKYErrorUnexpectedError];
        }
    }

    NSDictionary *errorDictionary = responseDictionary[@"error"];
    if ([errorDictionary isKindOfClass:[NSDictionary class]]) {
        return [_errorCreator errorWithResponseDictionary:errorDictionary];
    } else {
        NSString *message =
            [NSString stringWithFormat:@"HTTP Status Code \"%ld\" indicates that an error "
                                       @"occurred, but no \"error\" dictionary exists.",
                                       (long)response.statusCode];
        return [_errorCreator errorWithCode:SKYErrorBadResponse
                                   userInfo:@{
                                       SKYErrorMessageKey : message,
                                   }];
    }
}

- (void)handleRequestCompletionWithData:(NSData *)data
                               response:(NSURLResponse *)response
                                  error:(NSError *)requestError
{
    if (requestError) {
        NSError *error;
        if ([requestError.domain isEqualToString:SKYOperationErrorDomain]) {
            error = requestError;
        } else {
            error = [_errorCreator errorWithCode:SKYErrorNetworkFailure
                                        userInfo:@{
                                            NSUnderlyingErrorKey : requestError,
                                        }];
        }
        [self didEncounterError:error];
        [self setFinished:YES];
        return;
    }

    NSAssert([response isKindOfClass:[NSHTTPURLResponse class]],
             @"Returned response is not NSHTTPURLResponse");
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    [_errorCreator setDefaultUserInfoObject:[response.URL copy]
                                     forKey:NSURLErrorFailingURLErrorKey];
    [_errorCreator setDefaultUserInfoObject:@(httpResponse.statusCode)
                                     forKey:SKYOperationErrorHTTPStatusCodeKey];

    if (httpResponse.statusCode >= 400) {
        [self didEncounterError:[self errorWithResponse:httpResponse data:data]];
        [self setFinished:YES];
        return;
    }

    [self handleResponseWithData:data];
    [self setFinished:YES];
}

- (void)handleResponseWithData:(NSData *)data
{
    NSError *error = nil;
    NSDictionary *responseDictionary = [self parseResponse:data error:&error];

    if (error) {
        [self didEncounterError:error];
        return;
    }

    _response = responseDictionary;
    SKYResponse *response = [self createResponseWithDictionary:responseDictionary];
    [self handleResponse:response];
}

- (void)didEncounterError:(NSError *)error
{
    _error = error;
    [self handleRequestError:error];

    if ([self isAuthFailureError:error] && _container.auth.authErrorHandler) {
        _container.auth.authErrorHandler(_container, _container.auth.currentAccessToken, error);
    }
}

- (void)handleRequestError:(NSError *)error
{
    // Do nothing. Subclass should implement this method to define custom behavior.
}

- (void)handleResponse:(SKYResponse *)response
{
    // Do nothing. Subclass should implement this method to define custom behavior.
}

- (BOOL)isAuthFailureError:(NSError *)error
{
    return [error.domain isEqualToString:SKYOperationErrorDomain] &&
           error.code == SKYErrorAccessTokenNotAccepted;
}

- (SKYResponse *)createResponseWithDictionary:(NSDictionary *)responseDictionary
{
    Class SKYResponseClass = [[self class] responseClass];
    return [[SKYResponseClass alloc] initWithDictionary:responseDictionary];
}

@end
