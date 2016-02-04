//
//  SKYQueryOperation+QueryUser.h
//  Pods
//
//  Created by atwork on 3/2/2016.
//
//

#import <SKYKit/SKYKit.h>

@interface SKYQueryOperation (QueryUser)

/**
 Returns an operation object that discovers users by their email.
 */
+ (instancetype)queryUsersOperationByEmails:(NSArray /* NSString */ *)emails;

/**
 Returns an operation object that queries users by their relation to the current user.
 */
+ (instancetype)queryUsersOperationByRelation:(SKYRelation *)relation;

@end
