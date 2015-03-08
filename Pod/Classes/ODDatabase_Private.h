//
//  ODDatabase_Private.h
//  askq
//
//  Created by Kenji Pa on 30/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODDatabase.h"

@interface ODDatabase ()

// TODO: look for a better way to override NS_UNAVAILABLE on init
- (instancetype)initWithContainer:(ODContainer *)container;

@end
