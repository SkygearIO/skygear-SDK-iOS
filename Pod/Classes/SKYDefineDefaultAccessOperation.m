//
//  SKYDefineCreationAccessOperation.m
//  SKYKit
//
//  Copyright 2017 Oursky Ltd.
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

#import "SKYDefineDefaultAccessOperation.h"
#import "SKYAccessControlSerializer.h"

@implementation SKYDefineDefaultAccessOperation

+ (instancetype)operationWithRecordType:(NSString *)recordType
                          accessControl:(SKYAccessControl *)accessControl
{
    return [[SKYDefineDefaultAccessOperation alloc]
        initWithRecordType:recordType
             accessControl:(SKYAccessControl *)accessControl];
}

- (instancetype)initWithRecordType:(NSString *)recordType
                     accessControl:(SKYAccessControl *)accessControl
{
    self = [super init];
    if (self) {
        _recordType = recordType;
        _accessControl = accessControl;
    }

    return self;
}

// override
- (void)prepareForRequest
{
    if (!self.recordType) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Record type should not be nil"
                                     userInfo:nil];
    }

    id serialized =
        [[SKYAccessControlSerializer serializer] arrayWithAccessControl:self.accessControl];

    self.request = [[SKYRequest alloc]
        initWithAction:@"schema:default_access"
               payload:@{@"type" : self.recordType, @"default_access" : serialized}];
    self.request.APIKey = self.container.APIKey;
    self.request.accessToken = self.container.auth.currentAccessToken;
}

// override
- (void)operationWillStart
{
    [super operationWillStart];
    if (!self.container.auth.currentAccessToken) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"SKYContainer has no currently logged-in user"
                                     userInfo:nil];
    }
}

// override
- (void)handleRequestError:(NSError *)error
{
    if (self.defineDefaultAccessCompletionBlock) {
        self.defineDefaultAccessCompletionBlock(nil, nil, error);
    }
}

// override
- (void)handleResponse:(SKYResponse *)aResponse
{
    if (self.defineDefaultAccessCompletionBlock) {
        self.defineDefaultAccessCompletionBlock(self.recordType, self.accessControl, nil);
    }
}
@end
