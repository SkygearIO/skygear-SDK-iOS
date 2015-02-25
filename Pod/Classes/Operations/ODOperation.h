//
//  ODOperation.h
//  askq
//
//  Created by Kenji Pa on 21/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ODContainer.h"
#import "ODRequest.h"

@interface ODOperation : NSOperation

@property(nonatomic, strong) ODContainer *container;
@property(nonatomic, strong) ODRequest *request;
@property(nonatomic, readonly) NSDictionary *response;
@property(nonatomic, readonly) NSError *error;

- (instancetype)initWithRequest:(ODRequest *)request;
- (void)prepareForRequest;

@end
