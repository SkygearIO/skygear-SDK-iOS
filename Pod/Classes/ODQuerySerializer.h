//
//  ODPredicateSerializer.h
//  Pods
//
//  Created by Patrick Cheung on 14/3/15.
//
//

#import <Foundation/Foundation.h>

@interface ODQuerySerializer : NSObject

+ (instancetype)serializer;
- (NSArray *)arrayWithPredicate:(NSPredicate *)predicate;
- (NSArray *)arrayWithSortDescriptors:(NSArray *)sortDescriptors;

@end
