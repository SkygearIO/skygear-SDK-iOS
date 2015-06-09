//
//  ODUserDeserializer.h
//  Pods
//
//  Created by Kenji Pa on 1/6/15.
//
//

#import "ODUser.h"

@interface ODUserDeserializer : NSObject

+ (instancetype)deserializer;

- (ODUser *)userWithDictionary:(NSDictionary *)dictionary;

@end
