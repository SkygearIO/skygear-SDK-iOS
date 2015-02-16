//
//  ODNewsfeed.m
//  askq
//
//  Created by Kenji Pa on 16/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODNewsfeed.h"

@implementation ODNewsfeed

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        _identifier = identifier;
    }
    return self;
}

@end
