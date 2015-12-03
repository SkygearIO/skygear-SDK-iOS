//
//  SKYRelationPredicate.h
//  Pods
//
//  Created by atwork on 3/12/2015.
//
//

#import <Foundation/Foundation.h>

@class SKYRelation;

/**
 * The <SKYRelationPredicate> specifies a condition by whether a user
 * relation exists between two user, one being the user saved in a record
 * attribute an another being the current user.
 */
@interface SKYRelationPredicate : NSPredicate

/**
 * Returns the relation in the predicate.
 */
@property (nonatomic, readonly) SKYRelation *relation;

/**
 * Returns the key path of the attribute to be compared. The attribute should
 * store the user ID of a user.
 */
@property (nonatomic, readonly) NSString *keyPath;

/**
 * Returns an instance of <SKYRelationPredicate>.
 */
+ (instancetype)predicateWithRelation:(SKYRelation *)relation keyPath:(NSString *)keyPath;

@end
