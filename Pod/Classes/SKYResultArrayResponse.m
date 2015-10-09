//
//  SKYResultArrayResponse.m
//  Pods
//
//  Created by atwork on 15/8/15.
//
//

#import "SKYResultArrayResponse.h"
#import "SKYOperation.h"
#import "SKYDataSerialization.h"

@implementation SKYResultArrayResponse {
    NSArray *resultArrayInResponse;
}

- (instancetype)initWithDictionary:(NSDictionary *)response
{
    self = [super initWithDictionary:response];
    if (self) {
        resultArrayInResponse = self.responseDictionary[@"result"];
        if (![resultArrayInResponse isKindOfClass:[NSArray class]]) {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey:@"Server returned malformed result."
                                       };
            NSError *error = [NSError errorWithDomain:(NSString *)SKYOperationErrorDomain
                                                 code:0
                                             userInfo:userInfo];
            [self foundResponseError:error];
        }
    }
    return self;
}

- (NSUInteger)count
{
    return [resultArrayInResponse count];
}

- (void)enumerateResultsUsingBlock:(void (^)(NSString *resultKey, NSDictionary *result, NSError *error, NSUInteger idx, BOOL *stop))block
{
    if (!block) {
        return;
    }
    
    [resultArrayInResponse enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSError *error;
        if (![obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey:@"Result does not conform with expected format."
                                       };
            error = [NSError errorWithDomain:(NSString *)SKYOperationErrorDomain
                                        code:0
                                    userInfo:userInfo];
            block(nil, nil, error, idx, stop);
            return;
        }
        
        NSDictionary *result = (NSDictionary *)obj;
        NSString *resultKey = result[@"_id"];
        if (![resultKey isKindOfClass:[NSString class]]) {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey:@"Missing `_id` or not in correct format."
                                       };
            error = [NSError errorWithDomain:(NSString *)SKYOperationErrorDomain
                                        code:0
                                    userInfo:userInfo];
            block(nil, nil, error, idx, stop);
            return;
        }
        
        if ([result[@"_type"] isEqualToString:@"error"]) {
            NSMutableDictionary *userInfo = [SKYDataSerialization userInfoWithErrorDictionary:obj];
            error = [NSError errorWithDomain:(NSString *)SKYOperationErrorDomain
                                        code:0
                                    userInfo:userInfo];
            block(resultKey, nil, error, idx, stop);
            return;
        }
        
        block(resultKey, result, nil, idx, stop);
    }];
}

@end
