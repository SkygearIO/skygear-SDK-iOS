//
//  SKYResponse.h
//  Pods
//
//  Created by atwork on 15/8/15.
//
//

#import <Foundation/Foundation.h>

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
@property (nonatomic, readonly) NSError *error;

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
