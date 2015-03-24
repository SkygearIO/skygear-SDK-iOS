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

- (instancetype)initWithDeviceToken:(NSString *)deviceToken;

@property (nonatomic, readonly, copy) NSString *deviceToken;
@property (nonatomic, readwrite, copy) NSString *deviceID;
@property(nonatomic, copy) void (^registerCompletionBlock)(NSString *deviceID, NSError *error);



@end
