//
//  ODNewsfeed.h
//  askq
//
//  Created by Kenji Pa on 16/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ODReference.h"

@interface ODNewsfeed : NSObject

- (instancetype)initWithIdentifier:(NSString *)identifier;

@property (nonatomic, copy) NSString *identifier;

@end
