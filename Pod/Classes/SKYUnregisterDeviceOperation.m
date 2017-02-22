//
//  SKYUnregisterDeviceOperation.m
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

#import "SKYOperationSubclass.h"

#import "SKYUnregisterDeviceOperation.h"

@interface SKYUnregisterDeviceOperation ()

@property (nonatomic, readwrite, copy) NSString *deviceID;

@end

@implementation SKYUnregisterDeviceOperation

+ (instancetype)operationWithDeviceID:(nonnull NSString *)deviceID
{
    return [[self alloc] initWithDeviceID:deviceID];
}

- (instancetype)initWithDeviceID:(nonnull NSString *)deviceID
{
    self = [super init];
    if (self) {
        self.deviceID = [deviceID copy];
    }

    return self;
}

- (void)prepareForRequest
{
    self.request =
        [[SKYRequest alloc] initWithAction:@"device:unregister" payload:@{
            @"id" : self.deviceID
        }];
    self.request.APIKey = self.container.APIKey;
    self.request.accessToken = self.container.currentAccessToken;
}

- (void)handleResponse:(SKYResponse *)response
{
    NSDictionary *dict = response.responseDictionary;
    NSString *deviceID = dict[@"result"][@"id"];
    NSError *error = nil;
    if (deviceID == nil) {
        error = [self.errorCreator errorWithCode:SKYErrorInvalidData
                                         message:@"Response missing device id"];
    }

    if (self.unregisterCompletionBlock != nil) {
        self.unregisterCompletionBlock(deviceID, error);
    }
}

- (void)handleRequestError:(NSError *)error
{
    if (self.unregisterCompletionBlock != nil) {
        self.unregisterCompletionBlock(nil, error);
    }
}

@end
