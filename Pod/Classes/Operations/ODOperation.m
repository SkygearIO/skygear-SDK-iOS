//
//  ODOperation.m
//  askq
//
//  Created by Kenji Pa on 21/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODOperation.h"
#import "ODContainer_Private.h"
#import "NSURLRequest+ODRequest.h"
#import "NSError+ODError.h"
#import "ODError.h"
#import "ODDataSerialization.h"
#import "ODResponse.h"

NSString * const ODOperationErrorDomain = @"ODOperationErrorDomain";
NSString * const ODOperationErrorHTTPStatusCodeKey = @"ODOperationErrorHTTPStatusCodeKey";

@implementation ODOperation {
    BOOL _executing;
    BOOL _finished;
    NSError *_error;
    NSDictionary *_response;
    NSHTTPURLResponse *_httpResponse;
}

+ (Class)responseClass
{
    return [ODResponse class];
}

- (instancetype)init
{
    if ((self = [super init])) {
        [self resetCompletionBlock];
    }
    return self;
}

- (instancetype)initWithRequest:(ODRequest *)request;
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
    return [NSURLRequest requestWithODRequest:self.request];
}

- (void)prepareForRequest
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)operationWillStart
{
    if (![self container]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"The operation being started does not have a ODContainer set to the `container` property."
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
                          [self ODOperation_handleRequestCompletionWithData:data response:response error:error];
                      }];
    [task resume];
}

- (NSError *)errorFromURLSessionError:(NSError *)error
{
    NSDictionary *userInfo = @{
                               NSUnderlyingErrorKey: error,
                               NSLocalizedDescriptionKey: error.localizedDescription,
                               };
    return [NSError errorWithDomain:ODOperationErrorDomain
                               code:ODErrorNetworkFailure
                           userInfo:userInfo];
}

- (NSMutableDictionary *)errorUserInfoWithLocalizedDescription:(NSString *)description errorDictionary:(NSDictionary *)dict
{
    NSMutableDictionary *userInfo = [dict isKindOfClass:[NSDictionary class]] ? [ODDataSerialization userInfoWithErrorDictionary:dict] : [NSMutableDictionary dictionary];
    userInfo[NSLocalizedDescriptionKey] = [description copy];
    if (_httpResponse) {
        userInfo[NSURLErrorFailingURLErrorKey] = [_httpResponse.URL copy];
        userInfo[ODOperationErrorHTTPStatusCodeKey] = @(_httpResponse.statusCode);
    }
    
    return userInfo;
}

- (void)ODOperation_handleRequestCompletionWithData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error
{
    _httpResponse = [response isKindOfClass:[NSHTTPURLResponse class]] ? (NSHTTPURLResponse *)response : nil;

    if (error) {
        _error = [self errorFromURLSessionError:error];
    } else if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        // A NSHTTPURLResponse is required to check the HTTP status code of the response, which
        // is required to determine if an error occurred.
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Returned response is not NSHTTPURLResponse."
                                     userInfo:nil];
    } else {
        BOOL httpStatusCodeIsError = (_httpResponse.statusCode >= 400 && _httpResponse.statusCode < 600);
        NSError *jsonError;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:&jsonError];
        
        if (httpStatusCodeIsError) {
            NSMutableDictionary *userInfo = nil;
            NSDictionary *errorDictionary = responseDictionary[@"error"];
            if ([errorDictionary isKindOfClass:[NSDictionary class]]) {
                userInfo = [self errorUserInfoWithLocalizedDescription:@"An error occurred while processing the request."
                                                       errorDictionary:errorDictionary];
            } else {
                // An error occurred but the error dictionary does not exists or is of incorrect type.
                NSString *localizedDescription = nil;
                if (_httpResponse.statusCode < 500) {
                    localizedDescription = @"An unknown error occurred due to client error.";
                } else {
                    localizedDescription = @"An unknown error occurred due to server error.";
                }
                NSMutableDictionary *userInfo = [self errorUserInfoWithLocalizedDescription:localizedDescription
                                                                            errorDictionary:nil];
                if (jsonError) {
                    userInfo[NSUnderlyingErrorKey] = jsonError;
                }
            }
            
            error = [NSError errorWithDomain:ODOperationErrorDomain
                                        code:0
                                    userInfo:userInfo];
        } else {
            // If there is no error occurred in JSON decoding, and if response dictionary exists, there is no problem with
            // the response (so far). Otherwise, create an NSError stating that there is a malformed response.
            if (jsonError || ![responseDictionary isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *userInfo = nil;
                userInfo = [self errorUserInfoWithLocalizedDescription:@"The server sent a malformed response."
                                                       errorDictionary:nil];
                if (jsonError) {
                    userInfo[NSUnderlyingErrorKey] = jsonError;
                }
                error = [NSError errorWithDomain:ODOperationErrorDomain
                                            code:0
                                        userInfo:userInfo];
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
            ODResponse *response = [strongSelf createResponseWithDictionary:strongSelf->_response];
            [strongSelf handleResponse:response];
        }
    };
}

- (void)handleRequestError:(NSError *)error
{
    // Do nothing. Subclass should implement this method to define custom behavior.
}

- (void)handleResponse:(ODResponse *)response
{
    // Do nothing. Subclass should implement this method to define custom behavior.
}

- (BOOL)isAuthFailureError:(NSError *)error
{
    NSDictionary *userInfo = error.userInfo;
    return [userInfo[ODErrorTypeKey] isEqualToString:@"AuthenticationError"] && [userInfo[ODErrorCodeKey] integerValue] == 101;
}

- (ODResponse *)createResponseWithDictionary:(NSDictionary *)responseDictionary
{
    Class ODResponseClass = [[self class] responseClass];
    return [[ODResponseClass alloc] initWithDictionary:responseDictionary];

}

@end
