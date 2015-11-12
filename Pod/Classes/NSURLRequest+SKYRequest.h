//
//  NSURLRequest+SKYRequest.h
//  Pods
//
//  Created by Patrick Cheung on 24/2/15.
//
//

#import <Foundation/Foundation.h>
#import "SKYRequest.h"

extern NSString *const SKYRequestHeaderAPIKey;
extern NSString *const SKYRequestHeaderAccessTokenKey;

@interface NSURLRequest (SKYRequest)

+ (NSURLRequest *)requestWithSKYRequest:(SKYRequest *)request;

@end
