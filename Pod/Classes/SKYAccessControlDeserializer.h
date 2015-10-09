//
//  SKYAccessControlDeserializer.h
//  Pods
//
//  Created by Kenji Pa on 12/6/15.
//
//

#import <Foundation/Foundation.h>

#import "SKYAccessControl.h"

@interface SKYAccessControlDeserializer : NSObject

+ (instancetype)deserializer;

- (SKYAccessControl *)accessControlWithArray:(NSArray *)array;

@end
