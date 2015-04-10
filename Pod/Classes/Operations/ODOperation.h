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

extern const NSString * ODOperationErrorDomain;
extern const NSString * ODOperationErrorHTTPStatusCodeKey;

@interface ODOperation : NSOperation

@property(nonatomic, strong) ODContainer *container;
@property(nonatomic, strong) ODRequest *request;
@property(nonatomic, readonly) NSDictionary *response;
@property(nonatomic, readonly) NSError *error;

- (instancetype)initWithRequest:(ODRequest *)request;

/**
 Prepares the operation before a request takes place. You should implement this method by creating a <ODRequest> object
 and setting the object to the <request> property.
 
 The default implementation of this method throws an exception.
 
 This method is only called by <ODOperation> when the <request> property is <nil>.
 */
- (void)prepareForRequest;

- (void)operationWillStart;

- (NSMutableDictionary *)errorUserInfoWithLocalizedDescription:(NSString *)description errorDictionary:(NSDictionary *)dict;

@end
