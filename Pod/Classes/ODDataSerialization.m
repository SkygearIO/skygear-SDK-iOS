//
//  ODDataSerialization.m
//  Pods
//
//  Created by Patrick Cheung on 14/3/15.
//
//

#import "ODDataSerialization.h"

#import <CoreLocation/CoreLocation.h>

#import "ODAsset_Private.h"
#import "ODReference.h"
#import "ODError.h"

NSString * const ODDataSerializationCustomTypeKey = @"$type";
NSString * const ODDataSerializationAssetType = @"asset";
NSString * const ODDataSerializationReferenceType = @"ref";
NSString * const ODDataSerializationDateType = @"date";
NSString * const ODDataSerializationLocationType = @"geo";

static NSDictionary *remoteFunctionNameDict;
static NSDictionary *localFunctionNameDict;

NSString *remoteFunctionName(NSString *localFunctionName) {
    NSString *remoteName = remoteFunctionNameDict[localFunctionName];
    if (!remoteName.length) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"Unrecgonized local function name `%@`", localFunctionName] userInfo:nil];
    }
    return remoteName;
}

NSString *localFunctionName(NSString *remoteFunctionName) {
    NSString *localName = localFunctionNameDict[remoteFunctionName];
    if (!localName.length) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"Unrecgonized remote function name `%@`", remoteFunctionName] userInfo:nil];
    }
    return localName;
}

@implementation ODDataSerialization

+ (void)initialize
{
    remoteFunctionNameDict = @{@"distanceToLocation:fromLocation:": @"distance"};

    NSMutableDictionary *localFunctionNameMutableDict = [NSMutableDictionary dictionary];
    [remoteFunctionNameDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        localFunctionNameMutableDict[obj] = key;
    }];
    localFunctionNameDict = localFunctionNameMutableDict;
}

+ (id)deserializeSimpleObjectWithType:(NSString *)type value:(NSDictionary *)data
{
    id obj = nil;
    if ([type isEqualToString:ODDataSerializationDateType]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        obj = [formatter dateFromString:data[@"$date"]];
    } else if ([type isEqualToString:ODDataSerializationReferenceType]) {
        ODRecordID *recordID = [[ODRecordID alloc] initWithCanonicalString:data[@"$id"]];
        obj = [[ODReference alloc] initWithRecordID:recordID];
    } else if ([type isEqualToString:ODDataSerializationAssetType]) {
        obj = [self deserializeAssetWithDictionary:data];
    } else if ([type isEqualToString:ODDataSerializationLocationType]) {
        obj = [self deserializeLocationWithDictionary:data];
    }
    return obj;
}

+ (id)deserializeObjectWithValue:(id)value
{
    if (!value) {
        return nil;
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSMutableArray *newArray = [NSMutableArray array];
        [(NSArray *)value enumerateObjectsUsingBlock:^(id valueInArray, NSUInteger idx, BOOL *stop) {
            [newArray addObject:[self deserializeObjectWithValue:valueInArray]];
        }];
        return newArray;
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        NSString *type = [(NSDictionary *)value objectForKey:ODDataSerializationCustomTypeKey];
        if (type) {
            return [self deserializeSimpleObjectWithType:type value:value];
        } else {
            NSMutableDictionary *newDictionary = [NSMutableDictionary dictionary];
            [(NSDictionary *)value enumerateKeysAndObjectsUsingBlock:^(id key, id valueInDictionary, BOOL *stop) {
                [newDictionary setObject:[self deserializeObjectWithValue:valueInDictionary]
                                  forKey:key];
            }];
            return newDictionary;
        }
    } else {
        return value;
    }
}

+ (ODAsset *)deserializeAssetWithDictionary:(NSDictionary *)data
{
    NSString *name = data[@"$name"];
    NSString *rawURL = data[@"$url"];

    NSURL *url = nil;
    if (name.length && rawURL.length) {
        url = [NSURL URLWithString:rawURL];
    } else {
        return nil;
    }

    return [ODAsset assetWithName:name url:url];
}

+ (CLLocation *)deserializeLocationWithDictionary:(NSDictionary *)data
{
    double lng = [data[@"$lng"] doubleValue];
    double lat = [data[@"$lat"] doubleValue];

    return [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat, lng)
                                         altitude:0
                               horizontalAccuracy:0
                                 verticalAccuracy:0
                                        timestamp:[NSDate dateWithTimeIntervalSince1970:0]];
}

+ (id)serializeSimpleObject:(id)obj
{
    id data = nil;
    if ([obj isKindOfClass:[NSDate class]]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        data = @{
                 ODDataSerializationCustomTypeKey: ODDataSerializationDateType,
                 @"$date": [formatter stringFromDate:obj],
                 };
    } else if ([obj isKindOfClass:[ODReference class]]) {
        data = @{
                 ODDataSerializationCustomTypeKey: ODDataSerializationReferenceType,
                 @"$id": [(ODReference*)obj recordID].canonicalString,
                 };
    } else if ([obj isKindOfClass:[ODAsset class]]) {
        data = @{
                 ODDataSerializationCustomTypeKey: ODDataSerializationAssetType,
                 @"$name": [obj name],
                 };
    } else if ([obj isKindOfClass:[CLLocation class]]) {
        CLLocationCoordinate2D coordinate = [obj coordinate];
        data = @{
                 ODDataSerializationCustomTypeKey: ODDataSerializationLocationType,
                 @"$lng": @(coordinate.longitude),
                 @"$lat": @(coordinate.latitude),
                 };
    } else {
        data = obj;
    }
    return data;
}

+ (id)serializeObject:(id)obj
{
    if (!obj) {
        return nil;
    }
    
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *newArray = [NSMutableArray array];
        [(NSArray *)obj enumerateObjectsUsingBlock:^(id objInArray, NSUInteger idx, BOOL *stop) {
            [newArray addObject:[self serializeObject:objInArray]];
        }];
        return newArray;
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *newDictionary = [NSMutableDictionary dictionary];
        [(NSDictionary *)obj enumerateKeysAndObjectsUsingBlock:^(id key, id objInDictionary, BOOL *stop) {
            [newDictionary setObject:[self serializeObject:objInDictionary]
                              forKey:key];
        }];
        return newDictionary;
    } else {
        return [self serializeSimpleObject:obj];
    }
}

+ (NSMutableDictionary *)userInfoWithErrorDictionary:(NSDictionary *)dict
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    if ([dict[@"code"] isKindOfClass:[NSNumber class]]) {
        userInfo[ODErrorCodeKey] = [NSNumber numberWithInteger:[dict[@"code"] integerValue]];
    } else {
        NSLog(@"`code` is missing in error object or it is not a number.");
    }
    
    if ([dict[@"type"] isKindOfClass:[NSString class]]) {
        userInfo[ODErrorTypeKey] = [dict[@"type"] copy];
    } else {
        NSLog(@"`type` is missing in error object or it is not a string.");
    }
    
    if ([dict[@"message"] isKindOfClass:[NSString class]]) {
        userInfo[ODErrorMessageKey] = [dict[@"message"] copy];
    } else {
        NSLog(@"`message` is missing in error object or it is not a string.");
    }


    if (dict[@"info"]) {
        if ([dict[@"info"] isKindOfClass:[NSDictionary class]]) {
            userInfo[ODErrorInfoKey] = [dict[@"info"] copy];
        } else {
            NSLog(@"`info` is not a dictionary.");
        }
    }
    
    return userInfo;
}

@end
