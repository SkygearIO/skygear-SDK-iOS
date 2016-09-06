//
//  SKYUserChannel.m
//  Pods
//
//  Created by Andrew Chung on 6/2/16.
//
//

#import "SKYUserChannel.h"

@implementation SKYUserChannel

- (id)init{
    return [SKYRecord recordWithRecordType:@"user_channel"];
}


- (void)setName:(NSString *)name{
    self[@"name"] = name;
}

- (NSString *)name{
    return self[@"name"];
}

@end
