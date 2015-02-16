//
//  ODOperation.m
//  askq
//
//  Created by Kenji Pa on 21/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODOperation.h"
#import "ODContainer_Private.h"

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
    if ((self = [super init])) {
        self.request = request;
    }
    return self;
}

- (BOOL)isAsynchronous
{
    return self.isNetworkEnabled ? YES : [super isAsynchronous];
}

- (BOOL)isExecuting
{
    return self.isNetworkEnabled ? _executing : [super isExecuting];
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
    return self.isNetworkEnabled ? _finished : [super isFinished];
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


/*
 TODO: When all ODOperation implements network request, this property
 should be removed.
 
 Since ODOperation make network request asynchronously, it overrides
 the start method without calling -main. -main is implemented by stub
 operation classes that does not make network request. This design
 is subject to change.
 */
- (BOOL)isNetworkEnabled
{
    return NO;
}

- (void)start
{
    if (!self.isNetworkEnabled) {
        [super start];
        return;
    }
    
    if (self.cancelled || self.executing || self.finished) {
        return;
    }
    
    [self setExecuting:YES];
    
    NSMutableDictionary *parameters = [self.request.payload mutableCopy];
    if (self.request.accessToken) {
        parameters[@"access_token"] = self.request.accessToken.tokenString;
    }
    parameters[@"action"] = self.request.action;
    AFHTTPRequestOperationManager *manager = [self.container requestManager];
    [manager POST:self.request.requestPath
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              [self setResponse:responseObject];
              [self setFinished:YES];
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              self.error = error;
              [self setFinished:YES];
          }];

}

@end
