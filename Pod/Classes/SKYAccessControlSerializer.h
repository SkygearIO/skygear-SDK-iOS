//
//  SKYAccessControlSerializer.h
//  Pods
//
//  Created by Kenji Pa on 11/6/15.
//
//

#import <Foundation/Foundation.h>

#import "SKYAccessControl.h"

@interface SKYAccessControlSerializer : NSObject

+ (instancetype)serializer;

- (NSArray *)arrayWithAccessControl:(SKYAccessControl *)accessControl;

@end
