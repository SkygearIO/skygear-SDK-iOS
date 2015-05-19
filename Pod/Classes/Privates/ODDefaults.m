//
//  ODDefaults.m
//  Pods
//
//  Created by Kenji Pa on 15/5/15.
//
//

#import "ODDefaults.h"

NSString * const ODDefaultsDeviceIDKey = @"_ourdDeviceID";

@interface ODDefaults()

@property (nonatomic, readonly, assign) NSUserDefaults *defaults;

@end

@implementation ODDefaults

+ (instancetype)sharedDefaults
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (NSString *)deviceID
{
    return [self.defaults stringForKey:ODDefaultsDeviceIDKey];
}

- (void)setDeviceID:(NSString *)deviceID
{
    [self.defaults setObject:deviceID forKey:ODDefaultsDeviceIDKey];
}

@end
