//
//  SKYRequest.h
//  askq
//
//  Created by Patrick Cheung on 8/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKYAccessToken.h"

@interface SKYRequest : NSObject

@property (nonatomic, copy) NSString *action;
@property (nonatomic, copy) NSDictionary *payload;
@property (nonatomic, strong) SKYAccessToken *accessToken;

/**
 Sets or returns the API key to be associated with the request.
 */
@property (nonatomic, strong) NSString *APIKey;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, readonly) NSString *requestPath;

- (instancetype)initWithAction:(NSString *)action payload:(NSDictionary *)payload;

@end
