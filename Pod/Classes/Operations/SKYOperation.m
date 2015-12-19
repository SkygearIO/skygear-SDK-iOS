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
#import "SKYOperationSubclass.h"
#import "SKYOperation_Private.h"
#import "SKYContainer_Private.h"
#import "NSURLRequest+SKYRequest.h"
#import "NSError+SKYError.h"
#import "SKYError.h"
#import "SKYDataSerialization.h"
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
        [self resetCompletionBlock];
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

- (NSURLRequest *)makeURLRequest
{
    if (!self.request) {
        [self prepareForRequest];
        self.request.baseURL = self.container.endPointAddress;
    }
    return [NSURLRequest requestWithSKYRequest:self.request];
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
    NSURLSessionTask *task;
    task = [session dataTaskWithRequest:[self makeURLRequest]
                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                          [self handleRequestCompletionWithData:data response:response error:error];
                      }];
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

- (NSDictionary *)processResponseWithData:(NSData *)data
                                 response:(NSHTTPURLResponse *)httpResponse
                                    error:(NSError **)error
{
    if (!error) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"error must not be nil"
                                     userInfo:nil];
    }

    [_errorCreator setDefaultUserInfoObject:[httpResponse.URL copy]
                                     forKey:NSURLErrorFailingURLErrorKey];
    [_errorCreator setDefaultUserInfoObject:@(httpResponse.statusCode)
                                     forKey:SKYOperationErrorHTTPStatusCodeKey];

    NSDictionary *response = [self parseResponse:data error:error];

    if (httpResponse.statusCode >= 500 && *error) {
        // There is an server error and the server sent a bad response.
        // Replace the bad response error with an appropriate server error.
        switch (httpResponse.statusCode) {
            case 503:
                *error = [_errorCreator errorWithCode:SKYErrorServiceUnavailable];
            default:
                *error = [_errorCreator errorWithCode:SKYErrorUnexpectedError];
                break;
        }
    }

    if (httpResponse.statusCode >= 400 && !*error) {
        // There is an error, and the server sent a good response. Create the error object
        // from the "error" dictionary.
        NSDictionary *errorDictionary = response[@"error"];
        if ([errorDictionary isKindOfClass:[NSDictionary class]]) {
            *error = [_errorCreator errorWithResponseDictionary:errorDictionary];
        } else {
            NSString *message =
                [NSString stringWithFormat:@"HTTP Status Code \"%ld\" indicates that an error "
                                           @"occurred, but no \"error\" dictionary exists.",
                                           (long)httpResponse.statusCode];
            *error = [_errorCreator errorWithCode:SKYErrorBadResponse
                                         userInfo:@{
                                             SKYErrorMessageKey : message,
                                         }];
        }
    }

    return response;
}

- (void)handleRequestCompletionWithData:(NSData *)data
                               response:(NSURLResponse *)response
                                  error:(NSError *)requestError
{
    if (requestError) {
        _response = nil;
        _error = [_errorCreator errorWithCode:SKYErrorNetworkFailure
                                     userInfo:@{
                                         NSUnderlyingErrorKey : requestError,
                                     }];
    } else if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        // A NSHTTPURLResponse is required to check the HTTP status code of the response, which
        // is required to determine if an error occurred.
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Returned response is not NSHTTPURLResponse."
                                     userInfo:nil];
    } else {
        NSError *error = nil;
        _response =
            [self processResponseWithData:data response:(NSHTTPURLResponse *)response error:&error];
        _error = error;
    }

    NSAssert(_error != nil || _response != nil, @"either error or response must be non nil");
    [self setFinished:YES];

    if ([self isAuthFailureError:_error] && _container.authErrorHandler) {
        _container.authErrorHandler(_container, _container.currentAccessToken, _error);
    }
}

- (void)resetCompletionBlock
{
    __block __weak typeof(self) weakSelf = self;
    self.completionBlock = ^{
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf->_error) {
            [strongSelf handleRequestError:strongSelf->_error];
        } else if (strongSelf->_response && [[strongSelf class] responseClass] != nil) {
            SKYResponse *response = [strongSelf createResponseWithDictionary:strongSelf->_response];
            [strongSelf handleResponse:response];
        }
    };
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
