//
//  SKYLocationSortDescriptor.m
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

#import "SKYLocationSortDescriptor.h"
#import <CoreLocation/CoreLocation.h>

@implementation SKYLocationSortDescriptor {
    NSString *_key;
    BOOL _ascending;
}

- (instancetype)initWithKey:(NSString *)key
           relativeLocation:(CLLocation *)relativeLocation
                  ascending:(BOOL)ascending
{
    self = [super init];
    if (self) {
        if (![relativeLocation isKindOfClass:[CLLocation class]]) {
            NSString *reason = [NSString
                stringWithFormat:@"location must be of class CLLocation. Got %@", relativeLocation];
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:reason
                                         userInfo:nil];
        }

        _key = [key copy];
        _ascending = ascending;
        _relativeLocation = [relativeLocation copy];
    }
    return self;
}

+ (instancetype)locationSortDescriptorWithKey:(NSString *)key
                             relativeLocation:(CLLocation *)relativeLocation
                                    ascending:(BOOL)ascending;
{
    return [[self alloc] initWithKey:key relativeLocation:relativeLocation ascending:ascending];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _key = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"key"];
        _relativeLocation =
            [aDecoder decodeObjectOfClass:[CLLocation class] forKey:@"relativeLocation"];
        _ascending = [aDecoder decodeBoolForKey:@"ascending"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_key forKey:@"key"];
    [aCoder encodeObject:_relativeLocation forKey:@"relativeLocation"];
    [aCoder encodeBool:_ascending forKey:@"ascending"];
}

- (NSString *)key
{
    return _key;
}

- (BOOL)ascending
{
    return _ascending;
}

- (NSComparisonResult)compareObject:(id)object1 toObject:(id)object2
{
    CLLocation *location1 = [object1 valueForKey:self.key];
    CLLocation *location2 = [object2 valueForKey:self.key];
    CLLocationDistance distance1 = [self.relativeLocation distanceFromLocation:location1];
    CLLocationDistance distance2 = [self.relativeLocation distanceFromLocation:location2];
    return distance1 < distance2 ? NSOrderedAscending
                                 : (distance2 < distance1 ? NSOrderedDescending : NSOrderedSame);
}

- (id)reversedSortDescriptor
{
    return [[[self class] alloc] initWithKey:self.key
                            relativeLocation:self.relativeLocation
                                   ascending:!self.ascending];
}

@end
