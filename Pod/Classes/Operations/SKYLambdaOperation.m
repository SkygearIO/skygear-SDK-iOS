//
//  SKYLambdaOperation.m
//  Pods
//
//  Created by atwork on 3/7/15.
//
//

#import "SKYLambdaOperation.h"

@implementation SKYLambdaOperation

- (instancetype)initWithAction:(NSString *)action arrayArguments:(NSArray *)arguments
{
    self = [super init];
    if (self) {
        _action = [action copy];
        _arrayArguments = [arguments copy];
    }
    return self;
}

- (instancetype)initWithAction:(NSString *)action dictionaryArguments:(NSDictionary *)arguments
{
    self = [super init];
    if (self) {
        _action = [action copy];
        _dictionaryArguments = [arguments copy];
    }
    return self;
}

+ (instancetype)operationWithAction:(NSString *)action arrayArguments:(NSArray *)arguments
{
    return [[self alloc] initWithAction:action arrayArguments:arguments];
}

+ (instancetype)operationWithAction:(NSString *)action dictionaryArguments:(NSDictionary *)arguments
{
    return [[self alloc] initWithAction:action dictionaryArguments:arguments];
}

- (void)prepareForRequest
{
    NSDictionary *payload = @{ @"args" : _arrayArguments ? _arrayArguments : _dictionaryArguments };
    self.request = [[SKYRequest alloc] initWithAction:self.action payload:payload];
    self.request.accessToken = self.container.currentAccessToken;
}

- (void)handleRequestError:(NSError *)error
{
    if (self.lambdaCompletionBlock) {
        self.lambdaCompletionBlock(nil, error);
    }
}

- (void)handleResponse:(SKYResponse *)responseObject
{
    NSDictionary *response = responseObject.responseDictionary;
    NSDictionary *resultDictionary = nil;
    NSError *error = nil;

    NSDictionary *responseDictionary = response[@"result"];
    if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
        resultDictionary = responseDictionary;
    } else {
        NSDictionary *userInfo =
            [self errorUserInfoWithLocalizedDescription:@"Server returned malformed result."
                                        errorDictionary:nil];
        error =
            [NSError errorWithDomain:(NSString *)SKYOperationErrorDomain code:0 userInfo:userInfo];
    }

    if (self.lambdaCompletionBlock) {
        self.lambdaCompletionBlock(resultDictionary, error);
    }
}

@end
