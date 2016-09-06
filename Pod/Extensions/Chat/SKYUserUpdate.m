//
//  SKYUserUpdate.m
//  Pods
//
//  Created by Andrew Chung on 6/6/16.
//
//

#import "SKYUserUpdate.h"

@implementation SKYUserUpdate

- (void)setUsername:(NSString *)username{
    self[@"username"] = username;
}

- (NSString *)username{
    return self[@"username"];
}

- (void)setEmail:(NSString *)email{
    self[@"email"] = email;
}

- (NSString *)email{
    return self[@"email"];
}

@end
