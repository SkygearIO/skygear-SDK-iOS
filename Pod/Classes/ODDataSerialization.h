//
//  ODDataSerialization.h
//  Pods
//
//  Created by Patrick Cheung on 14/3/15.
//
//

#import <Foundation/Foundation.h>

extern const NSString *ODDataSerializationCustomTypeKey;
extern const NSString *ODDataSerializationReferenceType;
extern const NSString *ODDataSerializationDateType;

@interface ODDataSerialization : NSObject

+ (id)deserializeObjectWithValue:(id)value;
+ (id)serializeObject:(id)obj;

@end
