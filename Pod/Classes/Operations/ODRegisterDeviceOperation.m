//
//  ODRegisterDeviceOperation.m
//  Pods
//
//  Created by atwork on 24/3/15.
//
//

#import "ODRegisterDeviceOperation.h"

@implementation ODRegisterDeviceOperation

- (instancetype)initWithDeviceToken:(NSString *)deviceToken
{
    self = [super init];
    if (self) {
        _deviceToken = [deviceToken copy];
        _deviceID = nil;
    }
    return self;
}

- (void)prepareForRequest
{
    NSMutableDictionary *payload = [@{
                                      @"type": @"ios",
                                      @"device_token": self.deviceToken,
                                      } mutableCopy];
    if (self.deviceID) {
        payload[@"id"] = self.deviceID;
    }

    self.request = [[ODRequest alloc] initWithAction:@"device:register"
                                             payload:payload];
    self.request.accessToken = self.container.currentAccessToken;
}

- (void)setRegisterCompletionBlock:(void (^)(NSString *, NSError *))registerCompletionBlock
{
    [self willChangeValueForKey:@"registerCompletionBlock"];
    _registerCompletionBlock = [registerCompletionBlock copy];
    if (self.registerCompletionBlock) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            weakSelf.registerCompletionBlock(weakSelf.response[@"id"], weakSelf.error);
        };
    } else {
        self.completionBlock = nil;
    }
    [self didChangeValueForKey:@"registerCompletionBlock"];
}


@end
