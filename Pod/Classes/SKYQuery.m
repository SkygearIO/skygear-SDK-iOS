//
//  SKYQuery.m
//  SKYKit
//
//  Copyright 2015 Oursky Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "SKYQuery.h"

@implementation SKYQuery

- (instancetype)initWithRecordType:(NSString *)recordType predicate:(NSPredicate *)predicate
{
    self = [super init];
    if (self) {
        _recordType = recordType;
        _predicate = predicate;
    }
    return self;
}

+ (instancetype)queryWithRecordType:(NSString *)recordType predicate:(NSPredicate *)predicate
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
        NSSet *set = [NSSet setWithArray:@[ [NSArray class], [NSSortDescriptor class] ]];
        self.sortDescriptors = [aDecoder decodeObjectOfClasses:set forKey:@"sortDescriptors"];
        set = [NSSet setWithArray:@[ [NSArray class], [NSString class] ]];
        self.transientIncludes = [aDecoder decodeObjectOfClasses:set forKey:@"transientIncludes"];
        self.limit = [aDecoder decodeIntegerForKey:@"limit"];
        self.offset = [aDecoder decodeIntegerForKey:@"offset"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.predicate forKey:@"predicate"];
    [aCoder encodeObject:self.recordType forKey:@"recordType"];
    [aCoder encodeObject:self.sortDescriptors forKey:@"sortDescriptors"];
    [aCoder encodeObject:self.transientIncludes forKey:@"transientIncludes"];
    [aCoder encodeInteger:self.limit forKey:@"limit"];
    [aCoder encodeInteger:self.offset forKey:@"offset"];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - equals and hash

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[SKYQuery class]])
        return NO;
    SKYQuery *other = (SKYQuery *)object;
    return ((self.predicate == nil && other.predicate == nil) ||
            [self.predicate isEqual:other.predicate]) &&
           ((self.recordType == nil && other.recordType == nil) ||
            [self.recordType isEqual:other.recordType]) &&
           ((self.sortDescriptors == nil && other.sortDescriptors == nil) ||
            [self.sortDescriptors isEqual:other.sortDescriptors]) &&
           ((self.transientIncludes == nil && other.transientIncludes == nil) ||
            [self.transientIncludes isEqual:other.transientIncludes]) &&
           (self.limit == other.limit) && (self.offset == other.offset);
}

- (NSUInteger)hash
{
    return [self.predicate hash] ^ [self.recordType hash] ^ [self.sortDescriptors hash] ^
           [self.transientIncludes hash] ^ self.limit ^ self.offset;
}

@end
