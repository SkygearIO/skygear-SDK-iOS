//
//  NSURLRequest+SKYRequest.m
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

#import "NSURLRequest+SKYRequest.h"

NSString *const SKYRequestHeaderAPIKey = @"X-Skygear-API-Key";
NSString *const SKYRequestHeaderAccessTokenKey = @"X-Skygear-Access-Token";

@implementation NSURLRequest (SKYRequest)

+ (NSMutableURLRequest *)mutableRequestWithSKYRequest:(SKYRequest *)request
{
    NSURL *url = [NSURL URLWithString:request.requestPath relativeToURL:request.baseURL];

    NSMutableDictionary *parameters = [request.payload mutableCopy];
    if (request.accessToken) {
        parameters[@"access_token"] = [request.accessToken.tokenString copy];
    }
    if (request.APIKey) {
        parameters[@"api_key"] = [request.APIKey copy];
    }
    parameters[@"action"] = [request.action copy];

    NSError *error = nil;
    NSData *requestContent =
        [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPMethod = @"POST";
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[[NSNumber numberWithUnsignedInteger:[requestContent length]] stringValue]
        forHTTPHeaderField:@"Content-Length"];
    urlRequest.HTTPBody = requestContent;
    return urlRequest;
}

+ (NSURLRequest *)requestWithSKYRequest:(SKYRequest *)request
{
    return [[NSMutableURLRequest mutableRequestWithSKYRequest:request] copy];
}

@end
