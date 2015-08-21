//
//  ODLocationSortDescriptor.h
//  Pods
//
//  Created by atwork on 19/8/15.
//
//

#import <Foundation/Foundation.h>

@class CLLocation;

@interface ODLocationSortDescriptor : NSSortDescriptor <NSSecureCoding>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithKey:(NSString *)key
           relativeLocation:(CLLocation *)relativeLocation
                  ascending:(BOOL)ascending NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
+ (instancetype)locationSortDescriptorWithKey:(NSString *)key
                             relativeLocation:(CLLocation *)relativeLocation
                                    ascending:(BOOL)ascending;

@property (nonatomic, copy, readonly) CLLocation *relativeLocation;

@end
