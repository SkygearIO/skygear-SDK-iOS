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

const NSString * ODOperationErrorDomain = @"ODOperationErrorDomain";

@interface ODOperation ()

@property (nonatomic, strong) NSError *error;
@property (nonatomic, copy) NSDictionary *response;

@end

@implementation ODOperation {
    BOOL _executing;
    BOOL _finished;
    NSDictionary *_response;
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

- (NSDictionary *)response
{
    return _response;
}

- (void)setResponse:(NSDictionary *)anObject
{
    [self willChangeValueForKey:@"response"];
    _response = [anObject copy];
    [self didChangeValueForKey:@"response"];
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

- (void)ODOperation_handleRequestCompletionWithData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error
{
    NSError *responseError;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                       options:0
                                                                         error:&responseError];
    
    if (error) {
        // do nothing
    } else if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        error = [NSError errorWithDomain:(NSString *)ODOperationErrorDomain
                                    code:0
                                userInfo:@{
                                           NSLocalizedDescriptionKey: @"Returned response is not NSHTTPURLResponse."
                                           }];
    } else {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        responseDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:&error];
        
        if (!error) {
            if (![responseDictionary isKindOfClass:[NSDictionary class]]) {
                error = [NSError errorWithDomain:(NSString *)ODOperationErrorDomain
                                            code:0
                                        userInfo:@{
                                                   NSLocalizedDescriptionKey: @"The JSON object returned does not conformed to the expected format.",
                                                   NSURLErrorFailingURLErrorKey: response.URL
                                                   }];
                responseDictionary = nil;
            }
        }
        
        if (httpResponse.statusCode >= 400 && httpResponse.statusCode < 500) {
            error = [NSError errorWithDomain:(NSString *)ODOperationErrorDomain
                                        code:0
                                    userInfo:@{
                                               NSLocalizedDescriptionKey: @"An error occurred due to client error.",
                                               NSURLErrorFailingURLErrorKey: response.URL
                                               }];
        } else if (httpResponse.statusCode >= 500) {
            error = [NSError errorWithDomain:(NSString *)ODOperationErrorDomain
                                        code:0
                                    userInfo:@{
                                               NSLocalizedDescriptionKey: @"An error occurred due to server error.",
                                               NSURLErrorFailingURLErrorKey: response.URL
                                               }];
        }
    }
    
    self.error = error;
    [self setResponse:responseDictionary];
    [self setFinished:YES];
}

@end
