//
//  NSError+SKYError.m
//  Pods
//
//  Created by atwork on 29/3/15.
//
//

#import "NSError+SKYError.h"
#import "SKYError.h"

@implementation NSError (SKYError)

- (NSInteger)SKYErrorCode
{
    NSNumber *code = [self userInfo][SKYErrorCodeKey];
    return [code isKindOfClass:[NSNumber class]] ? [code integerValue] : 0;
}

- (NSString *)SKYErrorMessage
{
    NSString *message = [self userInfo][SKYErrorMessageKey];
    return [message isKindOfClass:[NSString class]] ? message : nil;
}

- (NSString *)SKYErrorType
{
    NSString *type = [self userInfo][SKYErrorTypeKey];
    return [type isKindOfClass:[NSString class]] ? type : nil;
}

- (NSDictionary *)SKYErrorInfo
{
    NSDictionary *info = [self userInfo][SKYErrorInfoKey];
    return [info isKindOfClass:[NSDictionary class]] ? info : nil;
}

@end
