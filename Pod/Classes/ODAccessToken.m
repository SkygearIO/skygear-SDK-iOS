//
//  ODAccessToken.m
//  askq
//
//  Created by Patrick Cheung on 8/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODAccessToken.h"

@implementation ODAccessToken

- (instancetype)initWithTokenString:(NSString *)tokenString
{
    if ((self = [super init])) {
        self.tokenString = tokenString;
    }
    return self;
}

@end
