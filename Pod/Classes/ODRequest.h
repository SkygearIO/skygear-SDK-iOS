//
//  ODRequest.h
//  askq
//
//  Created by Patrick Cheung on 8/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ODAccessToken.h"

@interface ODRequest : NSObject

@property(nonatomic, copy) NSString *action;
@property(nonatomic, copy) NSDictionary *payload;
@property(nonatomic, strong) ODAccessToken *accessToken;
@property(nonatomic, readonly) NSString *requestPath;
@property(nonatomic, readonly) NSURL *baseURL;

- (instancetype)initWithAction:(NSString *)action payload:(NSDictionary *)payload;

@end
