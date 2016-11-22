//
//  SKYUnknownValue.m
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

#import "SKYUnknownValue.h"

@implementation SKYUnknownValue

- (instancetype)init
{
    return [super init];
}

- (instancetype)initWithUnderlyingType:(NSString *)underlyingType
{
    if ((self = [super init])) {
        _underlyingType = [underlyingType copy];
    }
    return self;
}

+ (instancetype)unknownValueWithUnderlyingType:(NSString *)underlyingType
{
    return [[self alloc] initWithUnderlyingType:underlyingType];
}

#pragma NSCoding

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    NSString *underlyingType =
        [decoder decodeObjectOfClass:[NSString class] forKey:@"underlyingType"];
    return [SKYUnknownValue unknownValueWithUnderlyingType:underlyingType];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_underlyingType forKey:@"underlyingType"];
}

@end
