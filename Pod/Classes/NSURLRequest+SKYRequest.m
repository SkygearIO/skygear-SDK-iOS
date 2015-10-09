//
//  NSURLRequest+SKYRequest.m
//  Pods
//
//  Created by Patrick Cheung on 24/2/15.
//
//

#import "NSURLRequest+SKYRequest.h"

NSString * const SKYRequestHeaderAPIKey = @"X-Ourd-API-Key";
NSString * const SKYRequestHeaderAccessTokenKey = @"X-Ourd-Access-Token";

@implementation NSURLRequest (SKYRequest)

+ (NSURLRequest *)requestWithSKYRequest:(SKYRequest *)request
{
    NSURL *url = [NSURL URLWithString:request.requestPath
                        relativeToURL:request.baseURL];
    
    NSMutableDictionary *parameters = [request.payload mutableCopy];
    if (request.accessToken) {
        parameters[@"access_token"] = [request.accessToken.tokenString copy];
    }
    if (request.APIKey) {
        parameters[@"api_key"] = [request.APIKey copy];
    }
    parameters[@"action"] = [request.action copy];
    
    NSError *error = nil;
    NSData *requestContent = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
    
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPMethod = @"POST";
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[[NSNumber numberWithUnsignedInteger:[requestContent length]] stringValue]
   forHTTPHeaderField:@"Content-Length"];
    urlRequest.HTTPBody = requestContent;
    
    return urlRequest;
}

@end
