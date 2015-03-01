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

- (void)start
{
    if (!self.asynchronous) {
        [super start];
        return;
    }
    
    if (self.cancelled || self.executing || self.finished) {
        return;
    }
    
    [self setExecuting:YES];
    
    NSURLSessionConfiguration *myConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:myConfig];
    NSURLSessionTask *task;
    task = [session dataTaskWithRequest:[self makeURLRequest]
                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                          if (!error) {
                              id obj = [NSJSONSerialization JSONObjectWithData:data
                                                                       options:0
                                                                         error:nil];
                              [self setResponse:obj];
                          }
                          [self setFinished:YES];
                      }];
    [task resume];
}

@end
