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
#import "ODResponse.h"

extern NSString * const ODOperationErrorDomain;
extern NSString * const ODOperationErrorHTTPStatusCodeKey;

@interface ODOperation : NSOperation

@property(nonatomic, strong) ODContainer *container;
@property(nonatomic, strong) ODRequest *request;
@property(nonatomic, readonly) NSDictionary *response __deprecated;
@property(nonatomic, readonly) NSError *error __deprecated;

- (instancetype)initWithRequest:(ODRequest *)request;

/**
 Prepares the operation before a request takes place. You should implement this method by creating a <ODRequest> object
 and setting the object to the <request> property.
 
 The default implementation of this method throws an exception.
 
 This method is only called by <ODOperation> when the <request> property is <nil>.
 */
- (void)prepareForRequest;

/**
 Handles request error when operation completes.
 
 If an error has occurred when making the request or when processing the returned data,
 this method will be called to handle the error. Either this method or the -handleResponse:
 method will be called, but not both.
 
 The default implementation of this method does nothing. Subclass is expected to implement this
 method.
 */
- (void)handleRequestError:(NSError *)error;

/**
 Handles the response when operation completes.
 
 When no error occurred when making the request or when processing the returned data, this
 method will be called to handle the response. Either this method or the -handleRequestError:
 method will be called, but not both.
 
 The default implementation of this method does nothing. Subclass is expected to implement this
 method.
 */
- (void)handleResponse:(ODResponse *)response;

- (void)operationWillStart;

- (NSMutableDictionary *)errorUserInfoWithLocalizedDescription:(NSString *)description errorDictionary:(NSDictionary *)dict;

+ (Class)responseClass;

@end
