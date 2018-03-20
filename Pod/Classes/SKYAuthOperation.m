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
    SKYRecord *user = nil;
    SKYAccessToken *accessToken = nil;
    NSError *error = nil;

    NSDictionary *response = aResponse.responseDictionary[@"result"];

    if (self.authResponseDelegate) {
        [self.authResponseDelegate operation:self didCompleteWithAuthResponse:response];
    }

    NSDictionary *profile = response[@"profile"];
    NSString *recordID = profile[@"_id"];
    if ([recordID hasPrefix:@"user/"] && response[@"access_token"]) {
        user = [[SKYRecordDeserializer deserializer] recordWithDictionary:profile];
        accessToken = [[SKYAccessToken alloc] initWithTokenString:response[@"access_token"]];
    } else {
        error = [self.errorCreator errorWithCode:SKYErrorBadResponse
                                         message:@"Returned data does not contain expected data."];
    }

    if (!error) {
        NSLog(@"User logged in with UserRecordID %@.", user.recordID.recordName);
    }

    [self handleAuthResponseWithUser:user accessToken:accessToken error:error];
}

- (void)handleAuthResponseWithUser:(SKYRecord *)record
                       accessToken:(SKYAccessToken *)accessToken
                             error:(NSError *)error
{
    // Should be overridden by subclasses
}

@end
