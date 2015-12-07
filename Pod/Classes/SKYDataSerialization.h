//
//  SKYDataSerialization.h
//  Pods
//
//  Created by Patrick Cheung on 14/3/15.
//
//

#import <Foundation/Foundation.h>

#import "SKYAsset.h"

extern NSString *const SKYDataSerializationCustomTypeKey;
extern NSString *const SKYDataSerializationReferenceType;
extern NSString *const SKYDataSerializationDateType;
extern NSString *const SKYDataSerializationRelationType;

NSString *remoteFunctionName(NSString *localFunctionName);
NSString *localFunctionName(NSString *remoteFunctionName);

@interface SKYDataSerialization : NSObject

+ (id)deserializeObjectWithValue:(id)value;
+ (SKYAsset *)deserializeAssetWithDictionary:(NSDictionary *)data;

+ (id)serializeObject:(id)obj;

+ (NSMutableDictionary *)userInfoWithErrorDictionary:(NSDictionary *)dict;

@end
