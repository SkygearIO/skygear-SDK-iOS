//
//  SKYRelation.h
//  Pods
//
//  Created by Kenji Pa on 2/6/15.
//
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    SKYRelationDirectionOutward,
    SKYRelationDirectionInward,
    SKYRelationDirectionMutual
} SKYRelationDirection;

@interface SKYRelation : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)relationWithName:(NSString *)name direction:(SKYRelationDirection)direction;

+ (instancetype)friendRelation;
+ (instancetype)followingRelation;
+ (instancetype)followedRelation;

- (BOOL)isEqualToRelation:(SKYRelation *)relation;

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly) SKYRelationDirection direction;

@end
