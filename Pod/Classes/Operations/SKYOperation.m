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
#import "SKYOperation_Private.h"
#import "SKYContainer_Private.h"
#import "NSURLRequest+SKYRequest.h"
#import "NSError+SKYError.h"
#import "SKYError.h"
#import "SKYDataSerialization.h"
#import "SKYResponse.h"

NSString *const SKYOperationErrorDomain = @"SKYOperationErrorDomain";
NSString *const SKYOperationErrorHTTPStatusCodeKey = @"SKYOperationErrorHTTPStatusCodeKey";

@implementation SKYOperation {
    BOOL _executing;
    BOOL _finished;
    NSError *_error;
    NSDictionary *_response;
    NSHTTPURLResponse *_httpResponse;
}

+ (Class)responseClass
{
    return [SKYResponse class];
}

- (instancetype)init
{
    if ((self = [super init])) {
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
                          [self SKYOperation_handleRequestCompletionWithData:data
                                                                    response:response
                                                                       error:error];
                      }];
    [task resume];
}

- (NSError *)errorFromURLSessionError:(NSError *)error
{
    NSDictionary *userInfo = @{
        NSUnderlyingErrorKey : error,
        NSLocalizedDescriptionKey : error.localizedDescription,
    };
    return [NSError errorWithDomain:SKYOperationErrorDomain
                               code:SKYErrorNetworkFailure
                           userInfo:userInfo];
}

- (NSMutableDictionary *)errorUserInfoWithLocalizedDescription:(NSString *)description
                                               errorDictionary:(NSDictionary *)dict
{
    NSMutableDictionary *userInfo = [dict isKindOfClass:[NSDictionary class]]
                                        ? [SKYDataSerialization userInfoWithErrorDictionary:dict]
                                        : [NSMutableDictionary dictionary];
    userInfo[NSLocalizedDescriptionKey] = [description copy];
    if (_httpResponse) {
        userInfo[NSURLErrorFailingURLErrorKey] = [_httpResponse.URL copy];
        userInfo[SKYOperationErrorHTTPStatusCodeKey] = @(_httpResponse.statusCode);
    }

    return userInfo;
}

- (void)SKYOperation_handleRequestCompletionWithData:(NSData *)data
                                            response:(NSURLResponse *)response
                                               error:(NSError *)error
{
    _httpResponse =
        [response isKindOfClass:[NSHTTPURLResponse class]] ? (NSHTTPURLResponse *)response : nil;

    if (error) {
        _error = [self errorFromURLSessionError:error];
    } else if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        // A NSHTTPURLResponse is required to check the HTTP status code of the response, which
        // is required to determine if an error occurred.
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Returned response is not NSHTTPURLResponse."
                                     userInfo:nil];
    } else {
        BOOL httpStatusCodeIsError =
            (_httpResponse.statusCode >= 400 && _httpResponse.statusCode < 600);
        NSError *jsonError;
        NSDictionary *responseDictionary =
            [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

        if (httpStatusCodeIsError) {
            NSMutableDictionary *userInfo = nil;
            NSDictionary *errorDictionary = responseDictionary[@"error"];
            if ([errorDictionary isKindOfClass:[NSDictionary class]]) {
                userInfo = [self errorUserInfoWithLocalizedDescription:
                                     @"An error occurred while processing the request."
                                                       errorDictionary:errorDictionary];
            } else {
                // An error occurred but the error dictionary does not exists or is of incorrect
                // type.
                NSString *localizedDescription = nil;
                if (_httpResponse.statusCode < 500) {
                    localizedDescription = @"An unknown error occurred due to client error.";
                } else {
                    localizedDescription = @"An unknown error occurred due to server error.";
                }
                NSMutableDictionary *userInfo =
                    [self errorUserInfoWithLocalizedDescription:localizedDescription
                                                errorDictionary:nil];
                if (jsonError) {
                    userInfo[NSUnderlyingErrorKey] = jsonError;
                }
            }

            error = [NSError errorWithDomain:SKYOperationErrorDomain code:0 userInfo:userInfo];
        } else {
            // If there is no error occurred in JSON decoding, and if response dictionary exists,
            // there is no problem with
            // the response (so far). Otherwise, create an NSError stating that there is a malformed
            // response.
            if (jsonError || ![responseDictionary isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *userInfo = nil;
                userInfo = [self
                    errorUserInfoWithLocalizedDescription:@"The server sent a malformed response."
                                          errorDictionary:nil];
                if (jsonError) {
                    userInfo[NSUnderlyingErrorKey] = jsonError;
                }
                error = [NSError errorWithDomain:SKYOperationErrorDomain code:0 userInfo:userInfo];
                responseDictionary = nil;
            }
        }

        _error = error;
        _response = responseDictionary;
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
    NSDictionary *userInfo = error.userInfo;
    return [userInfo[SKYErrorTypeKey] isEqualToString:@"AuthenticationError"] &&
           [userInfo[SKYErrorCodeKey] integerValue] == 101;
}

- (SKYResponse *)createResponseWithDictionary:(NSDictionary *)responseDictionary
{
    Class SKYResponseClass = [[self class] responseClass];
    return [[SKYResponseClass alloc] initWithDictionary:responseDictionary];
}

@end
