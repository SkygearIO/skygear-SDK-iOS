//
//  ODAccessControlSerializer.h
//  Pods
//
//  Created by Kenji Pa on 11/6/15.
//
//

#import <Foundation/Foundation.h>

#import "ODAccessControl.h"

@interface ODAccessControlSerializer : NSObject

+ (instancetype)serializer;

- (NSArray *)arrayWithAccessControl:(ODAccessControl *)accessControl;

@end
