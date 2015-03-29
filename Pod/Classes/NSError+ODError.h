//
//  NSError+ODError.h
//  Pods
//
//  Created by atwork on 29/3/15.
//
//

#import <Foundation/Foundation.h>

@interface NSError (ODError)

- (NSString *)ODErrorMessage;
- (NSString *)ODErrorType;
- (NSInteger)ODErrorCode;
- (NSDictionary *)ODErrorInfo;

@end
