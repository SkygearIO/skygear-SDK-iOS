//
//  NSError+SKYError.h
//  Pods
//
//  Created by atwork on 29/3/15.
//
//

#import <Foundation/Foundation.h>

@interface NSError (SKYError)

- (NSString *)SKYErrorMessage;
- (NSString *)SKYErrorType;
- (NSInteger)SKYErrorCode;
- (NSDictionary *)SKYErrorInfo;

@end
