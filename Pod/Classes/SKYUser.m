//
//  SKYUser.m
//  askq
//
//  Created by Kenji Pa on 27/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYUser.h"

#import "SKYQueryOperation.h"

@interface SKYUser ()

@property (nonatomic, readwrite, copy) SKYUserRecordID *recordID;

@end

@implementation SKYUser

- (instancetype)initWithUserRecordID:(SKYUserRecordID *)recordID
{
    self = [super init];
    if (self) {
        _recordID = [recordID copy];
    }
    return self;
}

+ (instancetype)userWithUserRecordID:(SKYUserRecordID *)recordID
{
    return [[self alloc] initWithUserRecordID:recordID];
}

- (NSString *)username
{
    return self.recordID.username;
}

- (NSString *)email
{
    return self.recordID.email;
}

- (NSDictionary *)authData
{
    return self.recordID.authData;
}

- (SKYUserRecordID *)recordID
{
    return _recordID;
}

@end
