//
//  SKYOperation.h
//  SKYKit
//
//  Copyright 2015 Oursky Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>

#import "SKYContainer.h"
#import "SKYRequest.h"
#import "SKYResponse.h"

@interface SKYOperation : NSOperation

@property (nonatomic, strong) SKYContainer *container;
@property (nonatomic, strong) SKYRequest *request;

/**
 The maximum time to wait before the request is considered time out.
 */
@property (nonatomic, readwrite) NSTimeInterval timeoutInterval;

- (instancetype)initWithRequest:(SKYRequest *)request;

/**
 Prepares the operation before a request takes place. You should implement this method by creating a
 <SKYRequest> object
 and setting the object to the <request> property.

 The default implementation of this method throws an exception.

 This method is only called by <SKYOperation> when the <request> property is <nil>.
 You are not expected to call this method directly.
 */
- (void)prepareForRequest;

/**
 Handles request error when operation completes.

 If an error has occurred when making the request or when processing the returned data,
 this method will be called to handle the error. Either this method or the -handleResponse:
 method will be called, but not both.

 The default implementation of this method does nothing. Subclass is expected to implement this
 method. You are not expected to call this method directly.
 */
- (void)handleRequestError:(NSError *)error;

/**
 Handles the response data when operation completes.

 When no error occurred when making the request, this method will be called to handle the response
 data.

 The default implementation of this method parse the response and call -handleResponse:. If
 you override this method, -handleResponse: is not be called. You are not expected to call this
 method directly.
 */

- (void)handleResponseWithData:(NSData *)data;

/**
 Handles the parsed response when operation completes.

 When no error occurred when making the request or when processing the returned data, this
 method will be called to handle the response. Either this method or the -handleRequestError:
 method will be called, but not both.

 The default implementation of this method does nothing. Subclass is expected to implement this
 method. You are not expected to call this method directly.
 */
- (void)handleResponse:(SKYResponse *)response;

/**
 Create a <NSURLSessionTask> with the specified <NSURLSession> and <NSURLRequest>. <SKYOperation>
 calls this method to create a NSURLSessionTask.

 If you override this method, the task you created should call
 -handleRequestCompletionWithData:response:error:.


 This method is expected to be overriden by subclass of <SKYOperation>. You are not expected
 to call this method directly.
 */
- (NSURLSessionTask *)makeURLSessionTaskWithSession:(NSURLSession *)session
                                            request:(NSURLRequest *)request;

/**
 Creates a <NSURLRequest> with <SKYRequest> specified as the property of this class.
 <SKYOperation> calls this method to create a <NSURLRequest>.

 This method is expected to be overriden by subclass of <SKYOperation>. You are not expected
 to call this method directly.
 */
- (NSURLRequest *)makeURLRequest;

- (void)handleRequestCompletionWithData:(NSData *)data
                               response:(NSURLResponse *)response
                                  error:(NSError *)requestError;

- (void)operationWillStart;

+ (Class)responseClass;

@end
