//
//  SKYUserRecordID.m
//  askq
//
//  Created by Kenji Pa on 22/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "SKYUserRecordID.h"

@interface SKYUserRecordID()

@property (nonatomic, readwrite, copy) NSString *email;
@property (nonatomic, readwrite, copy) NSDictionary *authData;

@end

@implementation SKYUserRecordID

/**
 * Start: Private interface
 **/

+ (instancetype)recordIDWithUsername:(NSString *)username
{
    return [[self alloc] initWithUsername:username];
}

+ (instancetype)recordIDWithUsername:(NSString *)username email:(NSString *)email
{
    return [[self alloc] initWithUsername:username email:email];
}

+ (instancetype)recordIDWithUsername:(NSString *)username email:(NSString *)email authData:(NSDictionary *)authData
{
    return [[self alloc] initWithUsername:username email:email authData:authData];
}

- (instancetype)initWithUsername:(NSString *)username
{
    return [self initWithUsername:username email:nil];
}

- (instancetype)initWithUsername:(NSString *)username email:(NSString *)email
{
    return [self initWithUsername:username email:email authData:nil];
}

- (instancetype)initWithUsername:(NSString *)username email:(NSString *)email authData:(NSDictionary *)authData
{
    self = [super initWithRecordType:@"_user" name:username];
    if (self) {
        _email = [email copy];
        _authData = [authData copy];
    }
    return self;
}

/**
 * End: Private interface
 **/

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithUsername:[aDecoder decodeObjectOfClass:[NSString class] forKey:@"name"]
                            email:[aDecoder decodeObjectOfClass:[NSString class] forKey:@"email"]
                         authData:[aDecoder decodeObjectOfClass:[NSDictionary class] forKey:@"authData"]];
}

- (id)copyWithZone:(NSZone *)zone {
    SKYUserRecordID *recordID = [[self.class allocWithZone:zone] initWithUsername:self.username email:_email authData:_authData];
    return recordID;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.username forKey:@"name"];
    [aCoder encodeObject:_email forKey:@"email"];
    [aCoder encodeObject:_authData forKey:@"authData"];
}

- (BOOL)isEqual:(id)object
{
    if (!object) {
        return NO;
    }

    if (![object isKindOfClass:[SKYUserRecordID class]]) {
        return NO;
    }

    return [self isEqualToUserRecordID:object];
}

- (BOOL)isEqualToUserRecordID:(SKYUserRecordID *)recordID
{
    if (!recordID) {
        return NO;
    }

    return (
            ((recordID.username == nil && self.username == nil) || [recordID.username isEqual:self.username])
            && ((recordID.email == nil && self.email == nil) || [recordID.email isEqual:self.email])
            && ((recordID.authData == nil && self.authData == nil) || [recordID.authData isEqual:self.authData])
            );
}

- (NSUInteger)hash
{
    return [self.username hash] ^ [self.email hash] ^ [self.authData hash];
}

- (NSString *)username
{
    return self.recordName;
}

- (NSString *)email
{
    return _email;
}

@end
