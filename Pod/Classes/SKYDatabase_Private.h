//
//  SKYDatabase_Private.h
//  askq
//
//  Created by Kenji Pa on 30/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYDatabase.h"

@interface SKYDatabase ()

// TODO: look for a better way to override NS_UNAVAILABLE on init
- (instancetype)initWithContainer:(SKYContainer *)container;

@end
