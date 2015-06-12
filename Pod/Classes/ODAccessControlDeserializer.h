//
//  ODAccessControlDeserializer.h
//  Pods
//
//  Created by Kenji Pa on 12/6/15.
//
//

#import <Foundation/Foundation.h>

#import "ODAccessControl.h"

@interface ODAccessControlDeserializer : NSObject

+ (instancetype)deserializer;

- (ODAccessControl *)accessControlWithArray:(NSArray *)array;

@end
