//
//  ODRecordID.m
//  askq
//
//  Created by Kenji Pa on 20/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODRecordID.h"

@implementation ODRecordID

- (instancetype)init
{
    return [self initWithRecordType:nil name:nil];
}

- (instancetype)initWithRecordName:(NSString *)recordName {
    return [self initWithRecordType:nil name:recordName];
}

- (instancetype)initWithRecordType:(NSString *)type
{
    return [self initWithRecordType:type name:nil];
}

- (instancetype)initWithCanonicalString:(NSString *)canonicalString
{
    NSArray *components = [canonicalString componentsSeparatedByString:@"/"];
    if ([components count] != 2) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Invalid Record ID string."
                                     userInfo:nil];
    }
    
    return [self initWithRecordType:components[0] name:components[1]];
}

- (instancetype)initWithRecordType:(NSString *)type name:(NSString *)recordName
{
    self = [super init];
    if (self) {
        if (!type) {
            NSLog(@"Deprecation Warning: %@ created without record type.", NSStringFromClass([self class]));
        }
        _recordType = [type copy];
        _recordName = recordName ? [recordName copy] : [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithRecordType:[aDecoder decodeObjectOfClass:[NSString class] forKey:@"type"]
                               name:[aDecoder decodeObjectOfClass:[NSString class] forKey:@"name"]];
}

- (id)copyWithZone:(NSZone *)zone {
    ODRecordID *recordID = [[self.class allocWithZone:zone] initWithRecordType:[_recordType copyWithZone:zone]
                                                                          name:[_recordName copyWithZone:zone]];
    return recordID;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_recordName forKey:@"name"];
    [aCoder encodeObject:_recordType forKey:@"type"];
}

- (BOOL)isEqual:(id)object
{
    if (!object) {
        return NO;
    }
    
    if (![object isKindOfClass:[ODRecordID class]]) {
        return NO;
    }
    
    return [self isEqualToRecordID:object];
}

- (BOOL)isEqualToRecordID:(ODRecordID *)recordID
{
    if (!recordID) {
        return NO;
    }
    
    return (
            ((recordID.recordName == nil && self.recordName == nil) || [recordID.recordName isEqual:self.recordName])
            && ((recordID.recordType == nil && self.recordType == nil) || [recordID.recordType isEqual:self.recordType])
            );
}

- (NSUInteger)hash
{
    return [self.recordName hash] ^ [self.recordType hash];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; recordType = %@, recordName = %@>",
            NSStringFromClass([self class]), self, self.recordType, self.recordName];
}

- (NSString *)canonicalString
{
    return [NSString stringWithFormat:@"%@/%@", self.recordType, self.recordName];
}

+ (instancetype)recordIDWithCanonicalString:(NSString *)canonicalString
{
    NSArray *components = [canonicalString componentsSeparatedByString:@"/"];
    if ([components count] == 2) {
        return [[self alloc] initWithRecordType:components[0] name:components[1]];
    } else {
        return nil;
    }
}

@end
