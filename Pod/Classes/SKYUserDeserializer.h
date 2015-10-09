//
//  SKYUserDeserializer.h
//  Pods
//
//  Created by Kenji Pa on 1/6/15.
//
//

#import "SKYUser.h"

@interface SKYUserDeserializer : NSObject

+ (instancetype)deserializer;

- (SKYUser *)userWithDictionary:(NSDictionary *)dictionary;

@end
