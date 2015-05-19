//
//  ODRegisterDeviceOperation.m
//  Pods
//
//  Created by atwork on 24/3/15.
//
//

#import "ODRegisterDeviceOperation.h"

#import "ODDefaults.h"

@interface ODRegisterDeviceOperation()

@property (readonly) NSString *hexDeviceToken;

@end

@implementation ODRegisterDeviceOperation

- (instancetype)initWithDeviceToken:(NSData *)deviceToken
{
    self = [super init];
    if (self) {
        _deviceToken = [deviceToken copy];
        _deviceID = nil;
    }
    return self;
}

- (NSString *)hexDeviceToken {
    NSMutableString *token = [NSMutableString stringWithCapacity:2*self.deviceToken.length];

    [self.deviceToken enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        const unsigned char *bytePtr = bytes + byteRange.location,
            *endPtr = bytePtr + byteRange.length;
        for (;bytePtr < endPtr; ++bytePtr) {
            [token appendFormat:@"%02x", *bytePtr];
        }
    }];

    return token;
}

- (void)prepareForRequest
{
    NSMutableDictionary *payload = [@{
                                      @"type": @"ios",
                                      @"device_token": self.hexDeviceToken,
                                      } mutableCopy];

    NSString *deviceID;
    if (self.deviceID.length) {
        deviceID = self.deviceID;
    } else {
        deviceID = [ODDefaults sharedDefaults].deviceID;
    }
    if (deviceID.length) {
        payload[@"id"] = deviceID;
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
            NSError *error;
            NSDictionary *response = [weakSelf parseResponse:&error];

            NSString *deviceID = response[@"id"];
            if (deviceID.length) {
                [ODDefaults sharedDefaults].deviceID = deviceID;
            }
            weakSelf.registerCompletionBlock(deviceID, error);
        };
    } else {
        self.completionBlock = nil;
    }
    [self didChangeValueForKey:@"registerCompletionBlock"];
}

- (NSDictionary *)parseResponse:(NSError **)error
{
    if (self.error) {
        *error = self.error;
        return nil;
    }

    NSMutableDictionary* dict = [NSMutableDictionary dictionary];

    NSString *deviceID = self.response[@"result"][@"id"];
    if (!deviceID.length) {
        NSDictionary *userInfo = [self errorUserInfoWithLocalizedDescription:@"Response missing device id." errorDictionary:nil];
        *error = [NSError errorWithDomain:ODOperationErrorDomain code:0 userInfo:userInfo];
        return dict;
    }

    dict[@"id"] = deviceID;

    return dict;
}


@end
