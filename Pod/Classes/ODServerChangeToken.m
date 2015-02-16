//
//  ODServerChangeToken.m
//  askq
//
//  Created by Kenji Pa on 6/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODServerChangeToken.h"

@implementation ODServerChangeToken

- (id)copyWithZone:(NSZone *)zone {
    ODServerChangeToken *changeToken = [[self.class allocWithZone:zone] init];
    return changeToken;
}

@end
