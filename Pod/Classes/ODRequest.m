//
//  ODRequest.m
//  askq
//
//  Created by Patrick Cheung on 8/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODRequest.h"

@implementation ODRequest

- (instancetype)initWithAction:(NSString *)action payload:(NSDictionary *)payload
{
    if ((self = [super init])) {
        self.action = action;
        self.payload = payload;
    }
    return self;
}

- (void)setPayload:(NSDictionary *)payload
{
    [self willChangeValueForKey:@"payload"];
    if (payload) {
        _payload = [payload copy];
    } else {
        _payload = [[NSDictionary alloc] init];
    }
    [self didChangeValueForKey:@"payload"];
}

- (NSString *)requestPath
{
    if (self.action) {
        return [self.action stringByReplacingOccurrencesOfString:@":" withString:@"/"];
    } else {
        return nil;
    }
}

@end
