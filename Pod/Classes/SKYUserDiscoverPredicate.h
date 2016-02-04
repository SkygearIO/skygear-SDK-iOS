//
//  SKYUserDiscoverPredicate.h
//  Pods
//
//  Created by atwork on 3/2/2016.
//
//

#import <Foundation/Foundation.h>

/**
 * The <SKYUserDiscoverPredicate> specifies a condition to search for users
 * having the specified user data.
 */
@interface SKYUserDiscoverPredicate : NSPredicate

/**
 * Sets or returns user email.
 */
@property (nonatomic, readonly) NSArray *emails;

/**
 * Returns an instance of <SKYDiscoverPredicate>.
 */
+ (instancetype)predicateWithEmails:(NSArray *)emails;

@end
