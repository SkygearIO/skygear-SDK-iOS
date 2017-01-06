//
//  SKYRegisterDeviceOperation.m
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

#import "SKYRegisterDeviceOperation.h"
#import "SKYOperationSubclass.h"
#import "SKYOperation_Private.h"

@interface SKYRegisterDeviceOperation ()

@property (readonly) NSString *hexDeviceToken;

@end

@implementation SKYRegisterDeviceOperation

- (instancetype)initWithDeviceToken:(NSData *)deviceToken topic:(NSString *)topic
{
    self = [super init];
    if (self) {
        _deviceToken = [deviceToken copy];
        _topic = [topic copy];
        _deviceID = nil;
    }
    return self;
}

- (instancetype)initWithDeviceToken:(NSData *)deviceToken
{
    return [self initWithDeviceToken:deviceToken topic:nil];
}

+ (instancetype)operation
{
    return [[self alloc] initWithDeviceToken:nil];
}

+ (instancetype)operationWithDeviceToken:(NSData *)deviceToken
{
    return [[self alloc] initWithDeviceToken:deviceToken];
}

+ (instancetype)operationWithDeviceToken:(NSData *)deviceToken topic:(NSString *)topic
{
    return [[self alloc] initWithDeviceToken:deviceToken topic:topic];
}

- (NSString *)hexDeviceToken
{
    if (!self.deviceToken) {
        return nil;
    }

    NSMutableString *token = [NSMutableString stringWithCapacity:2 * self.deviceToken.length];

    [self.deviceToken
        enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
            const unsigned char *bytePtr = bytes + byteRange.location,
                                *endPtr = bytePtr + byteRange.length;
            for (; bytePtr < endPtr; ++bytePtr) {
                [token appendFormat:@"%02x", *bytePtr];
            }
        }];

    return token;
}

- (void)prepareForRequest
{
    NSMutableDictionary *payload = [@{
        @"type" : @"ios",
    } mutableCopy];

    NSString *deviceToken = self.hexDeviceToken;
    if (deviceToken) {
        payload[@"device_token"] = deviceToken;
    }

    NSString *topic = self.topic;
    if (topic.length) {
        payload[@"topic"] = topic;
    }

    NSString *deviceID = self.deviceID;
    if (deviceID.length) {
        payload[@"id"] = deviceID;
    }

    self.request = [[SKYRequest alloc] initWithAction:@"device:register" payload:payload];
    self.request.APIKey = self.container.APIKey;
    self.request.accessToken = self.container.currentAccessToken;
}

- (void)setRegisterCompletionBlock:(void (^)(NSString *, NSError *))registerCompletionBlock
{
    [self willChangeValueForKey:@"registerCompletionBlock"];
    _registerCompletionBlock = [registerCompletionBlock copy];
    if (self.registerCompletionBlock) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            NSError *error;
            NSDictionary *response = [weakSelf parseResponse:&error];

            NSString *deviceID = response[@"id"];
            weakSelf.registerCompletionBlock(deviceID, error);
        };
    } else {
        self.completionBlock = nil;
    }
    [self didChangeValueForKey:@"registerCompletionBlock"];
}

- (NSDictionary *)parseResponse:(NSError **)error
{
    if (self.error) {
        *error = self.error;
        return nil;
    }

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    NSString *deviceID = self.response[@"result"][@"id"];
    if (!deviceID.length) {
        if (error)
            *error = [self.errorCreator errorWithCode:SKYErrorInvalidData
                                              message:@"Response missing device id."];
    }

    dict[@"id"] = deviceID;

    return dict;
}

@end
