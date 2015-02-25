//
//  NSURLRequest+ODRequest.h
//  Pods
//
//  Created by Patrick Cheung on 24/2/15.
//
//

#import <Foundation/Foundation.h>
#import "ODRequest.h"

@interface NSURLRequest (ODRequest)

+ (NSURLRequest *)requestWithODRequest:(ODRequest *)request;

@end
