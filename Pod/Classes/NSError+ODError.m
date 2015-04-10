//
//  NSError+ODError.m
//  Pods
//
//  Created by atwork on 29/3/15.
//
//

#import "NSError+ODError.h"
#import "ODError.h"

@implementation NSError (ODError)

- (NSInteger)ODErrorCode
{
    NSNumber *code = [self userInfo][ODErrorCodeKey];
    return [code isKindOfClass:[NSNumber class]] ? [code integerValue] : 0;
}

- (NSString *)ODErrorMessage
{
    NSString *message = [self userInfo][ODErrorMessageKey];
    return [message isKindOfClass:[NSString class]] ? message : nil;
}

- (NSString *)ODErrorType
{
    NSString *type = [self userInfo][ODErrorTypeKey];
    return [type isKindOfClass:[NSString class]] ? type : nil;
}

- (NSDictionary *)ODErrorInfo
{
    NSDictionary *info = [self userInfo][ODErrorInfoKey];
    return [info isKindOfClass:[NSDictionary class]] ? info : nil;
}

@end
