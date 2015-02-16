//
//  ODUserRecordID.m
//  askq
//
//  Created by Kenji Pa on 22/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODUserRecordID.h"

@implementation ODUserRecordID

/**
 * Start: Private interface
 **/
- (instancetype)initWithUsername:(NSString *)username email:(NSString *)email recordName:(NSString *)recordName {
    self = [super initWithRecordName:recordName];
    if (self) {
        _username = username;
        _email = email;
    }
    return self;
}
/**
 * End: Private interface
 **/

@end
