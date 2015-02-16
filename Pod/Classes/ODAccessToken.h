//
//  ODAccessToken.h
//  askq
//
//  Created by Patrick Cheung on 8/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ODAccessToken : NSObject

@property (nonatomic, copy) NSString *tokenString;

- (instancetype)initWithTokenString:(NSString *)tokenString;

@end
