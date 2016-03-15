//
//  SKYResultArrayResponse.m
//  SKYKit
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
//

#import "SKYResultArrayResponse.h"
#import "SKYDataSerialization.h"
#import "SKYErrorCreator.h"
#import "SKYOperation.h"

@implementation SKYResultArrayResponse {
    NSArray *resultArrayInResponse;
    SKYErrorCreator *errorCreator;
}

- (instancetype)initWithDictionary:(NSDictionary *)response
{
    self = [super initWithDictionary:response];
    if (self) {
        errorCreator = [[SKYErrorCreator alloc] init];
        resultArrayInResponse = self.responseDictionary[@"result"];
        if (![resultArrayInResponse isKindOfClass:[NSArray class]]) {
            NSError *error = [errorCreator errorWithCode:SKYErrorBadResponse
                                                 message:@"Result is not an array or not exists."];
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
            error = [errorCreator errorWithCode:SKYErrorInvalidData
                                        message:@"Result does not conform with expected format."];
            block(nil, nil, error, idx, stop);
            return;
        }

        NSDictionary *result = (NSDictionary *)obj;
        NSString *resultKey = result[@"_id"];
        if (![resultKey isKindOfClass:[NSString class]]) {
            error = [errorCreator errorWithCode:SKYErrorInvalidData
                                        message:@"Missing `_id` or not in correct format."];
            block(nil, nil, error, idx, stop);
            return;
        }

        if ([result[@"_type"] isEqualToString:@"error"]) {
            error = [errorCreator errorWithResponseDictionary:obj];
            block(resultKey, nil, error, idx, stop);
            return;
        }

        block(resultKey, result, nil, idx, stop);
    }];
}

@end
