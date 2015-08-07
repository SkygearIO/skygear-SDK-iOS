//
//  ODQuery.m
//  askq
//
//  Created by Kenji Pa on 21/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODQuery.h"

@implementation ODQuery

- (instancetype)initWithRecordType:(NSString *)recordType
                         predicate:(NSPredicate *)predicate
{
    self = [super init];
    if (self) {
        _recordType = recordType;
        _predicate = predicate;
    }
    return self;
}

+ (instancetype)queryWithRecordType:(NSString *)recordType
                          predicate:(NSPredicate *)predicate
{
    return [[self alloc] initWithRecordType:recordType predicate:predicate];
}

#pragma mark - NSSecureCoding protocol

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSString *recordType = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"recordType"];
    NSPredicate *predicate = [aDecoder decodeObjectOfClass:[NSPredicate class] forKey:@"predicate"];
    self = [self initWithRecordType:recordType predicate:predicate];
    if (self) {
        NSSet *set = [NSSet setWithArray:@[[NSArray class], [NSSortDescriptor class]]];
        self.sortDescriptors = [aDecoder decodeObjectOfClasses:set
                                                        forKey:@"sortDescriptors"];
        set = [NSSet setWithArray:@[[NSArray class], [NSString class]]];
        self.eagerLoadKeyPath = [aDecoder decodeObjectOfClasses:set
                                                         forKey:@"eagerLoadKeyPath"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.predicate forKey:@"predicate"];
    [aCoder encodeObject:self.recordType forKey:@"recordType"];
    [aCoder encodeObject:self.sortDescriptors forKey:@"sortDescriptors"];
    [aCoder encodeObject:self.eagerLoadKeyPath forKey:@"eagerLoadKeyPath"];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - equals and hash

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[ODQuery class]]) return NO;
    ODQuery *other = (ODQuery *)object;
    return ((self.predicate == nil && other.predicate == nil) || [self.predicate isEqual:other.predicate]) &&
        ((self.recordType == nil && other.recordType == nil) || [self.recordType isEqual:other.recordType]) &&
        ((self.sortDescriptors == nil && other.sortDescriptors == nil) || [self.sortDescriptors isEqual:other.sortDescriptors]) &&
        ((self.eagerLoadKeyPath == nil && other.eagerLoadKeyPath == nil) || [self.eagerLoadKeyPath isEqual:other.eagerLoadKeyPath]);
}

- (NSUInteger)hash
{
    return [self.predicate hash] ^ [self.recordType hash] ^ [self.sortDescriptors hash] ^ [self.eagerLoadKeyPath hash];
}


@end
