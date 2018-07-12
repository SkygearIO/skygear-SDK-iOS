//
//  SKYAuthOperation.m
//  SKYKit
//
//  Copyright 2018 Oursky Ltd.
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

#import "SKYAuthOperation.h"

#import "SKYAuthOperation_Private.h"
#import "SKYRecordDeserializer.h"
#import "SKYResponse.h"

@implementation SKYAuthOperation

- (void)handleResponse:(SKYResponse *)aResponse
{
    NSError *error = nil;

    NSDictionary *response = aResponse.responseDictionary[@"result"];

    if (self.authResponseDelegate) {
        [self.authResponseDelegate operation:self didCompleteWithAuthResponse:response];
    }

    NSDictionary *profile = response[@"profile"];
    if (![profile isKindOfClass:[NSDictionary class]]) {
        error = [self.errorCreator errorWithCode:SKYErrorBadResponse
                                         message:@"Returned data does not contain expected data."];
    }

    SKYRecord *user =
        error ? nil : [[SKYRecordDeserializer deserializer] recordWithDictionary:profile];
    if (![user.recordID.recordType isEqualToString:@"user"]) {
        error = error ? error
                      : [self.errorCreator
                            errorWithCode:SKYErrorBadResponse
                                  message:@"Returned data does not contain expected data."];
    }

    NSString *tokenString = response[@"access_token"];
    if (![tokenString isKindOfClass:[NSString class]]) {
        tokenString = nil;
        error = error ? error
                      : [self.errorCreator
                            errorWithCode:SKYErrorBadResponse
                                  message:@"Returned data does not contain expected data."];
    }

    SKYAccessToken *accessToken =
        error ? nil : [[SKYAccessToken alloc] initWithTokenString:tokenString];

    [self handleAuthResponseWithUser:error ? nil : user
                         accessToken:error ? nil : accessToken
                               error:error];
}

- (void)handleAuthResponseWithUser:(SKYRecord *)record
                       accessToken:(SKYAccessToken *)accessToken
                             error:(NSError *)error
{
    // Should be overridden by subclasses
}

@end
