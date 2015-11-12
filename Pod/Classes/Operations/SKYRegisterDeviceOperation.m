//
//  SKYRegisterDeviceOperation.m
//  Pods
//
//  Created by atwork on 24/3/15.
//
//

#import "SKYRegisterDeviceOperation.h"

#import "SKYDefaults.h"

@interface SKYRegisterDeviceOperation ()

@property (readonly) NSString *hexDeviceToken;

@end

@implementation SKYRegisterDeviceOperation

- (instancetype)initWithDeviceToken:(NSData *)deviceToken
{
    self = [super init];
    if (self) {
        _deviceToken = [deviceToken copy];
        _deviceID = nil;
    }
    return self;
}

+ (instancetype)operation
{
    return [[self alloc] initWithDeviceToken:nil];
}

+ (instancetype)operationWithDeviceToken:(NSData *)deviceToken
{
    return [[self alloc] initWithDeviceToken:deviceToken];
}

- (NSString *)hexDeviceToken
{
    if (!self.deviceToken) {
        return nil;
    }

    NSMutableString *token = [NSMutableString stringWithCapacity:2 * self.deviceToken.length];

    [self.deviceToken
        enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
            const unsigned char *bytePtr = bytes + byteRange.location,
                                *endPtr = bytePtr + byteRange.length;
            for (; bytePtr < endPtr; ++bytePtr) {
                [token appendFormat:@"%02x", *bytePtr];
            }
        }];

    return token;
}

- (void)prepareForRequest
{
    NSMutableDictionary *payload = [@{
        @"type" : @"ios",
    } mutableCopy];

    NSString *deviceToken = self.hexDeviceToken;
    if (deviceToken) {
        payload[@"device_token"] = deviceToken;
    }

    NSString *deviceID;
    if (self.deviceID.length) {
        deviceID = self.deviceID;
    } else {
        deviceID = [SKYDefaults sharedDefaults].deviceID;
    }
    if (deviceID.length) {
        payload[@"id"] = deviceID;
    }

    self.request = [[SKYRequest alloc] initWithAction:@"device:register" payload:payload];
    self.request.APIKey = self.container.APIKey;
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
                [SKYDefaults sharedDefaults].deviceID = deviceID;
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

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    NSString *deviceID = self.response[@"result"][@"id"];
    if (!deviceID.length) {
        NSDictionary *userInfo =
            [self errorUserInfoWithLocalizedDescription:@"Response missing device id."
                                        errorDictionary:nil];
        *error = [NSError errorWithDomain:SKYOperationErrorDomain code:0 userInfo:userInfo];
        return dict;
    }

    dict[@"id"] = deviceID;

    return dict;
}

@end
