//
//  ODDataSerialization.h
//  Pods
//
//  Created by Patrick Cheung on 14/3/15.
//
//

#import <Foundation/Foundation.h>

extern NSString * const ODDataSerializationCustomTypeKey;
extern NSString * const ODDataSerializationReferenceType;
extern NSString * const ODDataSerializationDateType;

@interface ODDataSerialization : NSObject

+ (id)deserializeObjectWithValue:(id)value;
+ (id)serializeObject:(id)obj;
+ (NSMutableDictionary *)userInfoWithErrorDictionary:(NSDictionary *)dict;

@end
