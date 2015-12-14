//
//  SKYQueryDeserializer.m
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

#import "SKYQueryDeserializer.h"
#import "SKYDataSerialization.h"
#import "SKYLocationSortDescriptor.h"
#import "SKYRelationPredicate.h"

@implementation SKYQueryDeserializer

+ (instancetype)deserializer
{
    return [[self alloc] init];
}

- (SKYQuery *)queryWithDictionary:(NSDictionary *)dictionary
{
    NSString *recordType = dictionary[@"record_type"];
    if (!recordType.length) {
        return nil;
    }

    NSPredicate *predicate;
    NSArray *predicateArray = dictionary[@"predicate"];
    if (predicateArray.count) {
        predicate = [self predicateWithArray:predicateArray];
    }

    SKYQuery *query = [[SKYQuery alloc] initWithRecordType:recordType predicate:predicate];

    if ([dictionary[@"include"] isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *include = [NSMutableDictionary dictionary];
        [dictionary[@"include"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            include[key] = [self expressionWithObject:obj];
        }];
        query.transientIncludes = include;
    }

    NSArray *sortDescriptorArrays = dictionary[@"sort"];
    if (sortDescriptorArrays.count) {
        query.sortDescriptors = [self sortDescriptorsWithArray:sortDescriptorArrays];
    }

    NSNumber *limit = dictionary[@"limit"];
    if ([limit isKindOfClass:[NSNumber class]]) {
        query.limit = [limit integerValue];
    }

    NSNumber *offset = dictionary[@"offset"];
    if ([offset isKindOfClass:[NSNumber class]]) {
        query.offset = [offset integerValue];
    }

    NSNumber *overallCount = dictionary[@"count"];
    if ([overallCount isKindOfClass:[NSNumber class]]) {
        query.overallCount = [overallCount boolValue];
    }

    return query;
}

- (NSArray *)sortDescriptorsWithArray:(NSArray *)array
{
    NSMutableArray *sortDescriptors = [NSMutableArray arrayWithCapacity:array.count];
    for (NSArray *sortDescriptorArray in array) {
        NSSortDescriptor *sortDescriptor = [self sortDescriptorWithArray:sortDescriptorArray];
        if (sortDescriptorArray) {
            [sortDescriptors addObject:sortDescriptor];
        }
    }
    return sortDescriptors;
}

- (NSSortDescriptor *)sortDescriptorWithArray:(NSArray *)array
{
    if (array.count < 2) {
        return nil;
    }

    NSString *ordering = array[1];
    BOOL ascending;
    if ([ordering isEqualToString:@"asc"]) {
        ascending = YES;
    } else if ([ordering isEqualToString:@"desc"]) {
        ascending = NO;
    } else {
        NSLog(@"Unrecgonized sort ordering = %@", ordering);
        return nil;
    }

    NSExpression *expr = [self expressionWithObject:array[0]];
    switch (expr.expressionType) {
        case NSKeyPathExpressionType:
            if (expr.keyPath.length) {
                return [NSSortDescriptor sortDescriptorWithKey:expr.keyPath ascending:ascending];
            } else {
                return nil;
            }
            break;
        case NSFunctionExpressionType:
            if ([expr.function isEqualToString:@"distanceToLocation:fromLocation:"]) {
                NSExpression *arg1 = expr.arguments[0];
                NSExpression *arg2 = expr.arguments[1];
                return [SKYLocationSortDescriptor locationSortDescriptorWithKey:arg1.keyPath
                                                               relativeLocation:arg2.constantValue
                                                                      ascending:ascending];
            } else {
                NSLog(@"Function name %@ is not supported.", expr.function);
                return nil;
            }
            break;
        default:
            NSLog(@"Unsupport expression of type %lu.", (unsigned long)expr.expressionType);
            return nil;
    }
}

- (NSPredicate *)predicateWithArray:(NSArray *)array
{
    if (!array.count) {
        return nil;
    }

    NSPredicate *predicate;
    NSString *op = array[0];
    if ([@[ @"eq", @"gt", @"gte", @"lt", @"lte", @"neq", @"like", @"ilike", @"in" ]
            containsObject:op]) {
        predicate = [self comparisonPredicateWithArray:array];
    } else if ([@[ @"and", @"or", @"not" ] containsObject:op]) {
        predicate = [self compoundPredicateWithArray:array];
    } else if ([op isEqualToString:@"func"]) {
        predicate = [self functionalPredicateWithArray:array];
    }

    return predicate;
}

- (NSComparisonPredicate *)comparisonPredicateWithArray:(NSArray *)array
{
    if (array.count < 3) {
        return nil;
    }

    NSString *predicateOperatorTypeName = array[0];
    id lhs = array[1];
    id rhs = array[2];

    NSPredicateOperatorType predicateOperatorType;
    NSComparisonPredicateOptions options = 0;

    if ([predicateOperatorTypeName isEqualToString:@"eq"]) {
        predicateOperatorType = NSEqualToPredicateOperatorType;
    } else if ([predicateOperatorTypeName isEqualToString:@"gt"]) {
        predicateOperatorType = NSGreaterThanPredicateOperatorType;
    } else if ([predicateOperatorTypeName isEqualToString:@"gte"]) {
        predicateOperatorType = NSGreaterThanOrEqualToPredicateOperatorType;
    } else if ([predicateOperatorTypeName isEqualToString:@"lt"]) {
        predicateOperatorType = NSLessThanPredicateOperatorType;
    } else if ([predicateOperatorTypeName isEqualToString:@"lte"]) {
        predicateOperatorType = NSLessThanOrEqualToPredicateOperatorType;
    } else if ([predicateOperatorTypeName isEqualToString:@"neq"]) {
        predicateOperatorType = NSNotEqualToPredicateOperatorType;
    } else if ([predicateOperatorTypeName isEqualToString:@"like"]) {
        predicateOperatorType = NSLikePredicateOperatorType;
        if ([rhs isKindOfClass:[NSString class]]) {
            rhs = [self likePatternWithString:rhs];
        }
    } else if ([predicateOperatorTypeName isEqualToString:@"ilike"]) {
        predicateOperatorType = NSLikePredicateOperatorType;
        options = NSCaseInsensitivePredicateOption;
        if ([rhs isKindOfClass:[NSString class]]) {
            rhs = [self likePatternWithString:rhs];
        }
    } else if ([predicateOperatorTypeName isEqualToString:@"in"]) {
        predicateOperatorType = NSInPredicateOperatorType;
    } else {
        NSLog(@"Unrecgonized predicateOperatorType = %@", predicateOperatorTypeName);
        return nil;
    }

    NSExpression *leftExpression = [self expressionWithObject:lhs];
    NSExpression *rightExpression = [self expressionWithObject:rhs];

    return [NSComparisonPredicate predicateWithLeftExpression:leftExpression
                                              rightExpression:rightExpression
                                                     modifier:NSDirectPredicateModifier
                                                         type:predicateOperatorType
                                                      options:options];
}

- (NSString *)likePatternWithString:(NSString *)s
{
    NSMutableString *matchPattern = [s mutableCopy];
    [matchPattern replaceOccurrencesOfString:@"_"
                                  withString:@"?"
                                     options:0
                                       range:NSMakeRange(0, [matchPattern length])];
    [matchPattern replaceOccurrencesOfString:@"%"
                                  withString:@"*"
                                     options:0
                                       range:NSMakeRange(0, [matchPattern length])];
    return [matchPattern copy];
}

- (NSExpression *)expressionWithObject:(id)obj
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSString *objType = (NSString *)obj[@"$type"];
        if ([objType isEqualToString:@"keypath"]) {
            return [NSExpression
                expressionForKeyPath:[self keyPathWithDictionary:(NSDictionary *)obj]];
        }
    }

    if ([obj isKindOfClass:[NSArray class]] && [obj[0] isEqualToString:@"func"]) {
        NSArray *arr = obj;

        NSString *funcName = arr[1];
        NSString *ocFuncName = localFunctionName(funcName);

        NSMutableArray *args = [NSMutableArray arrayWithCapacity:arr.count - 1];
        for (NSUInteger i = 2; i < arr.count; ++i) {
            [args addObject:[self expressionWithObject:arr[i]]];
        }

        return [NSExpression expressionForFunction:ocFuncName arguments:args];
    }

    id constantValue = [SKYDataSerialization deserializeObjectWithValue:obj];
    return [NSExpression expressionForConstantValue:constantValue];
}

- (NSString *)keyPathWithDictionary:(NSDictionary *)dictionary
{
    NSString *keyPath;
    NSString *objectType = dictionary[@"$type"];
    if ([objectType isEqualToString:@"keypath"]) {
        keyPath = dictionary[@"$val"];
    }
    return keyPath;
}

- (NSCompoundPredicate *)compoundPredicateWithArray:(NSArray *)array
{
    NSString *compoundOperatorTypeName = array[0];
    NSCompoundPredicateType compoundOperatorType;
    if ([compoundOperatorTypeName isEqualToString:@"and"]) {
        compoundOperatorType = NSAndPredicateType;
    } else if ([compoundOperatorTypeName isEqualToString:@"or"]) {
        compoundOperatorType = NSOrPredicateType;
    } else if ([compoundOperatorTypeName isEqualToString:@"not"]) {
        compoundOperatorType = NSNotPredicateType;
    } else {
        NSLog(@"Unrecgonized compoundOperatorType = %@", compoundOperatorTypeName);
        return nil;
    }

    NSMutableArray *subpredicates = [NSMutableArray arrayWithCapacity:array.count - 1];
    for (uint i = 1; i < array.count; ++i) {
        NSArray *subpredicateArray = (NSArray *)array[i];
        if (subpredicateArray.count) {
            [subpredicates addObject:[self predicateWithArray:subpredicateArray]];
        } else {
            return nil;
        }
    }

    return
        [[NSCompoundPredicate alloc] initWithType:compoundOperatorType subpredicates:subpredicates];
}

- (NSPredicate *)functionalPredicateWithArray:(NSArray *)array
{
    if ([array[1] isEqualToString:@"userRelation"]) {
        NSExpression *keyPathExpr = [self expressionWithObject:array[2]];
        SKYRelation *relation = [SKYDataSerialization deserializeObjectWithValue:array[3]];
        return [SKYRelationPredicate predicateWithRelation:relation keyPath:[keyPathExpr keyPath]];
    } else {
        NSLog(@"Unexpected functional predicate %@.", array[1]);
        return [NSPredicate predicateWithValue:YES];
    }
}

@end
