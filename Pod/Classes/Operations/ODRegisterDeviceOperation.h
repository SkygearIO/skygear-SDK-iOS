//
//  ODRegisterDeviceOperation.h
//  Pods
//
//  Created by atwork on 24/3/15.
//
//

#import <Foundation/Foundation.h>
#import "ODOperation.h"

@interface ODRegisterDeviceOperation : ODOperation

- (instancetype)initWithDeviceToken:(NSData *)deviceToken;

+ (instancetype)operationWithDeviceToken:(NSData *)deviceToken;

@property (nonatomic, readonly, copy) NSData *deviceToken;
@property (nonatomic, readwrite, copy) NSString *deviceID;
@property (nonatomic, copy) void (^registerCompletionBlock)(NSString *deviceID, NSError *error);

@end
