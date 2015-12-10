//
//  SKYResultArrayResponse.m
//  SkyKit
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
            NSDictionary *userInfo =
                @{ NSLocalizedDescriptionKey : @"Server returned malformed result." };
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

- (void)enumerateResultsUsingBlock:(void (^)(NSString *resultKey, NSDictionary *result,
                                             NSError *error, NSUInteger idx, BOOL *stop))block
{
    if (!block) {
        return;
    }

    [resultArrayInResponse enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSError *error;
        if (![obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *userInfo =
                @{ NSLocalizedDescriptionKey : @"Result does not conform with expected format." };
            error = [NSError errorWithDomain:(NSString *)SKYOperationErrorDomain
                                        code:0
                                    userInfo:userInfo];
            block(nil, nil, error, idx, stop);
            return;
        }

        NSDictionary *result = (NSDictionary *)obj;
        NSString *resultKey = result[@"_id"];
        if (![resultKey isKindOfClass:[NSString class]]) {
            NSDictionary *userInfo =
                @{ NSLocalizedDescriptionKey : @"Missing `_id` or not in correct format." };
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
