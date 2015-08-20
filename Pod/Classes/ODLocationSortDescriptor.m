//
//  ODLocationSortDescriptor.m
//  Pods
//
//  Created by atwork on 19/8/15.
//
//

#import "ODLocationSortDescriptor.h"
#import <CoreLocation/CoreLocation.h>

@implementation ODLocationSortDescriptor {
    NSString * _key;
    BOOL _ascending;
}

- (instancetype)initWithKey:(NSString *)key
           relativeLocation:(CLLocation *)relativeLocation
                  ascending:(BOOL)ascending
{
    self = [super init];
    if (self) {
        if (![relativeLocation isKindOfClass:[CLLocation class]]) {
            NSString *reason = [NSString stringWithFormat:@"location must be of class CLLocation. Got %@", relativeLocation];
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
        _key = [aDecoder decodeObjectOfClass:[NSString class]
                                      forKey:@"key"];
        _relativeLocation = [aDecoder decodeObjectOfClass:[CLLocation class]
                                                   forKey:@"relativeLocation"];
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
    return distance1 < distance2 ? NSOrderedAscending : (distance2 < distance1 ? NSOrderedDescending : NSOrderedSame);
}

- (id)reversedSortDescriptor
{
    return [[[self class] alloc] initWithKey:self.key
                            relativeLocation:self.relativeLocation
                                   ascending:!self.ascending];
}

@end
