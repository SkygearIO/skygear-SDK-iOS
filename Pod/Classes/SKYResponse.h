//
//  SKYResponse.h
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

NS_ASSUME_NONNULL_BEGIN

/**
 <SKYResponse> encapsulates the response dictionary by providing convenient methods
 to access its content.

 <SKYResponse> is a generic class that is expected to be subclassed to implement other
 common pattern of response dictionary.
 */
@interface SKYResponse : NSObject

/**
 Gets the response dictionary used to create the <SKYResponse>.
 */
@property (nonatomic, readonly) NSDictionary *responseDictionary;

/**
 Gets the NSError that is contained within the responseDictionary or encountered
 when processing the responseDictionary.
 */
@property (nonatomic, readonly) NSError *_Nullable error;

/**
 Instantiates an instance of <SKYResponse>.

 Subclass is expected to implement this to implement custom processing for the response dictionary.
 */
- (instancetype)initWithDictionary:(NSDictionary *)response;

/**
 Returns an instance of <SKYResponse>.
 */
+ (instancetype)responseWithDictionary:(NSDictionary *)response;

/**
 Sets the NSError that is contained within the responseDictionary or encountered when processing
 the responseDictionary.

 The NSError can be set once only. This is expected to be called by a subclass to set the
 NSError encountered.
 */
- (void)foundResponseError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
