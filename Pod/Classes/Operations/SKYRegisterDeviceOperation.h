//
//  SKYRegisterDeviceOperation.h
//  Pods
//
//  Created by atwork on 24/3/15.
//
//

#import <Foundation/Foundation.h>
#import "SKYOperation.h"

@interface SKYRegisterDeviceOperation : SKYOperation

- (instancetype)initWithDeviceToken:(NSData *)deviceToken;

+ (instancetype)operationWithDeviceToken:(NSData *)deviceToken;

@property (nonatomic, readonly, copy) NSData *deviceToken;
@property (nonatomic, readwrite, copy) NSString *deviceID;
@property (nonatomic, copy) void (^registerCompletionBlock)(NSString *deviceID, NSError *error);

@end
