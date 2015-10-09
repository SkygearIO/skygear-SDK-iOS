//
//  SKYUserLogoutOperation.m
//  askq
//
//  Created by Patrick Cheung on 8/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYUserLogoutOperation.h"

@implementation SKYUserLogoutOperation

- (void)prepareForRequest
{
    self.request = [[SKYRequest alloc] initWithAction:@"auth:logout"
                                             payload:nil];
    self.request.accessToken = self.container.currentAccessToken;
}

- (void)setLogoutCompletionBlock:(void (^)(NSError *))logoutCompletionBlock
{
    if (logoutCompletionBlock) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            logoutCompletionBlock(weakSelf.error);
        };
    } else {
        self.completionBlock = nil;
    }
}

@end
