//
//  SKYServerChangeToken.m
//  askq
//
//  Created by Kenji Pa on 6/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYServerChangeToken.h"

@implementation SKYServerChangeToken

- (id)copyWithZone:(NSZone *)zone {
    SKYServerChangeToken *changeToken = [[self.class allocWithZone:zone] init];
    return changeToken;
}

@end
