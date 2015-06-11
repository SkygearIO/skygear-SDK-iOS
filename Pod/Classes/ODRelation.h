//
//  ODRelation.h
//  Pods
//
//  Created by Kenji Pa on 2/6/15.
//
//

#import <Foundation/Foundation.h>

@interface ODRelation : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)relationFollow;
+ (instancetype)relationFriend;

- (BOOL)isEqualToRelation:(ODRelation *)relation;

@property (nonatomic, readonly, copy) NSString *name;

@end
