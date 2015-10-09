//
//  SKYQueryDeserializer.h
//  Pods
//
//  Created by Kenji Pa on 22/4/15.
//
//

#import <Foundation/Foundation.h>
#import "SKYQuery.h"

@interface SKYQueryDeserializer : NSObject

+ (instancetype)deserializer;

- (SKYQuery *)queryWithDictionary:(NSDictionary *)dictionary;
- (NSExpression *)expressionWithObject:(id)obj;
- (NSPredicate *)predicateWithArray:(NSArray *)array;
- (NSArray *)sortDescriptorsWithArray:(NSArray *)array;

@end
