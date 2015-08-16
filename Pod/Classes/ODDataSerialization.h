//
//  ODDataSerialization.h
//  Pods
//
//  Created by Patrick Cheung on 14/3/15.
//
//

#import <Foundation/Foundation.h>

#import "ODAsset.h"

extern NSString * const ODDataSerializationCustomTypeKey;
extern NSString * const ODDataSerializationReferenceType;
extern NSString * const ODDataSerializationDateType;

NSString *remoteFunctionName(NSString *localFunctionName);
NSString *localFunctionName(NSString *remoteFunctionName);


@interface ODDataSerialization : NSObject

+ (id)deserializeObjectWithValue:(id)value;
+ (ODAsset *)deserializeAssetWithDictionary:(NSDictionary *)data;

+ (id)serializeObject:(id)obj;

+ (NSMutableDictionary *)userInfoWithErrorDictionary:(NSDictionary *)dict;

@end
