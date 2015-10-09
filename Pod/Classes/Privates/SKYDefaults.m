//
//  SKYDefaults.m
//  Pods
//
//  Created by Kenji Pa on 15/5/15.
//
//

#import "SKYDefaults.h"

NSString * const SKYDefaultsDeviceIDKey = @"_ourdDeviceID";

@interface SKYDefaults()

@property (nonatomic, readonly, assign) NSUserDefaults *defaults;

@end

@implementation SKYDefaults

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
    return [self.defaults stringForKey:SKYDefaultsDeviceIDKey];
}

- (void)setDeviceID:(NSString *)deviceID
{
    [self.defaults setObject:deviceID forKey:SKYDefaultsDeviceIDKey];
}

@end
