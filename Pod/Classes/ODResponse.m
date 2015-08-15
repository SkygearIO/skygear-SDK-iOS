//
//  ODResponse.m
//  Pods
//
//  Created by atwork on 15/8/15.
//
//

#import "ODResponse.h"

@implementation ODResponse

- (instancetype)initWithDictionary:(NSDictionary *)response
{
    self = [super init];
    if (self) {
        if (![response isKindOfClass:[NSDictionary class]]) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"response must be an NSDDictionary."
                                         userInfo:nil];
        }
        _responseDictionary = [response copy];
    }
    return self;
}

+ (instancetype)responseWithDictionary:(NSDictionary *)response
{
    return [[self alloc] initWithDictionary:response];
}

- (void)foundResponseError:(NSError *)error
{
    if (_error == nil) {
        _error = error;
    } else {
        @throw [NSException exceptionWithName:NSGenericException
                                       reason:@"error is already set"
                                     userInfo:nil];
    }
}

@end
