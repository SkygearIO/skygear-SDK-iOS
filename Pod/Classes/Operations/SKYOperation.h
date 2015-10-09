//
//  SKYOperation.h
//  askq
//
//  Created by Kenji Pa on 21/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SKYContainer.h"
#import "SKYRequest.h"
#import "SKYResponse.h"

extern NSString * const SKYOperationErrorDomain;
extern NSString * const SKYOperationErrorHTTPStatusCodeKey;

@interface SKYOperation : NSOperation

@property(nonatomic, strong) SKYContainer *container;
@property(nonatomic, strong) SKYRequest *request;
@property(nonatomic, readonly) NSDictionary *response __deprecated;
@property(nonatomic, readonly) NSError *error __deprecated;

- (instancetype)initWithRequest:(SKYRequest *)request;

/**
 Prepares the operation before a request takes place. You should implement this method by creating a <SKYRequest> object
 and setting the object to the <request> property.
 
 The default implementation of this method throws an exception.
 
 This method is only called by <SKYOperation> when the <request> property is <nil>.
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
- (void)handleResponse:(SKYResponse *)response;

- (void)operationWillStart;

- (NSMutableDictionary *)errorUserInfoWithLocalizedDescription:(NSString *)description errorDictionary:(NSDictionary *)dict;

+ (Class)responseClass;

@end
