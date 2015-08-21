//
//  ODQueryDeserializer.m
//  Pods
//
//  Created by Kenji Pa on 22/4/15.
//
//

#import "ODQueryDeserializer.h"
#import "ODDataSerialization.h"
#import "ODLocationSortDescriptor.h"

@implementation ODQueryDeserializer

+ (instancetype)deserializer
{
    return [[self alloc] init];
}

- (ODQuery *)queryWithDictionary:(NSDictionary *)dictionary
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

    ODQuery *query = [[ODQuery alloc] initWithRecordType:recordType predicate:predicate];

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

    return query;
}

- (NSArray *)sortDescriptorsWithArray:(NSArray *)array {
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
                return [NSSortDescriptor sortDescriptorWithKey:expr.keyPath
                                                     ascending:ascending];
            } else {
                return nil;
            }
            break;
        case NSFunctionExpressionType:
            if ([expr.function isEqualToString:@"distanceToLocation:fromLocation:"]) {
                NSExpression *arg1 = expr.arguments[0];
                NSExpression *arg2 = expr.arguments[1];
                return [ODLocationSortDescriptor locationSortDescriptorWithKey:arg1.keyPath
                                                              relativeLocation:arg2.constantValue
                                                                     ascending:ascending];
            } else {
                NSLog(@"Function name %@ is not supported.", expr.function);
                return nil;
            }
            break;
        default:
            NSLog(@"Unsupport expression of type %lu.", expr.expressionType);
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
    if ([@[@"eq", @"gt", @"gte", @"lt", @"lte", @"neq"] containsObject:op]) {
        predicate = [self comparisonPredicateWithArray:array];
    } else if ([@[@"and", @"or", @"not"] containsObject:op]) {
        predicate = [self compoundPredicateWithArray:array];
    }

    return predicate;
}

- (NSComparisonPredicate *)comparisonPredicateWithArray:(NSArray *)array
{
    if (array.count < 3) {
        return nil;
    }

    NSString *predicateOperatorTypeName = array[0];
    NSPredicateOperatorType predicateOperatorType;
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
    } else {
        NSLog(@"Unrecgonized predicateOperatorType = %@", predicateOperatorTypeName);
        return nil;
    }

    NSExpression *leftExpression = [self expressionWithObject:array[1]];
    NSExpression *rightExpression = [self expressionWithObject:array[2]];

    return [NSComparisonPredicate predicateWithLeftExpression:leftExpression
                                              rightExpression:rightExpression
                                                     modifier:NSDirectPredicateModifier
                                                         type:predicateOperatorType
                                                      options:0];
}

- (NSExpression *)expressionWithObject:(id)obj
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSString *objType = (NSString *)obj[@"$type"];
        if ([objType isEqualToString:@"keypath"]) {
            return [NSExpression expressionForKeyPath:[self keyPathWithDictionary:(NSDictionary *)obj]];
        }
    }

    if ([obj isKindOfClass:[NSArray class]]) {
        NSArray *arr = obj;

        NSString *funcName = arr[1];
        NSString *ocFuncName = localFunctionName(funcName);

        NSMutableArray *args = [NSMutableArray arrayWithCapacity:arr.count-1];
        for (NSUInteger i = 2; i < arr.count; ++i) {
            [args addObject:[self expressionWithObject:arr[i]]];
        }

        return [NSExpression expressionForFunction:ocFuncName arguments:args];
    }

    id constantValue = [ODDataSerialization deserializeObjectWithValue:obj];
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

    return [[NSCompoundPredicate alloc] initWithType:compoundOperatorType subpredicates:subpredicates];
}

@end
