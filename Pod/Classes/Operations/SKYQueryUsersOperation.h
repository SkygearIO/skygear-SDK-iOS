//
//  SKYDiscoverUserOperation.h
//  Pods
//
//  Created by Kenji Pa on 29/5/15.
//
//

#import "SKYOperation.h"

#import "SKYRelation.h"

typedef enum : NSUInteger {
    SKYUserDiscoveryMethodEmail = 0,
    SKYUserDiscoveryMethodRelation = 1,
} SKYUserDiscoveryMethod;

typedef enum : NSInteger {
    SKYRelationDirectionActive,
    SKYRelationDirectionPassive,
    SKYRelationDirectionMutual
} SKYRelationDirection;

/**
 <SKYQueryUsersOperation> is a subclass of <SKYOperation> that implements user query
 in Ourd. Use this operation to query other user in the same application.
 */
@interface SKYQueryUsersOperation : SKYOperation

/**
 Returns an operation object that discovers users by their email.
 */
+ (instancetype)discoverUsersOperationByEmails:(NSArray /* NSString */ *)emails;

/**
 Returns an operation object that queries users by their relation to the current user.
 */
+ (instancetype)queryUsersOperationByRelation:(SKYRelation *)relation;

/**
 Returns an operation object that queries users by their relation to the current user with the specified direction.
 */
+ (instancetype)queryUsersOperationByRelation:(SKYRelation *)relation direction:(SKYRelationDirection)direction;

/**
 Initializes and returns a email-based user discovery operation object.
 
 @param emails An array of emails to be used for user discovery.
 */
- (instancetype)initWithEmails:(NSArray /* NSString */ *)emails NS_DESIGNATED_INITIALIZER;

/**
 Initializes and returns a relation-based user query operation object.

 @param relation The relation object to be used for user discovery.
 */
- (instancetype)initWithRelation:(SKYRelation *)relation;

/**
 Initializes and returns a relation-based user query operation object with relation direction specified.

 @param relation The relation object to be used for user discovery.
 */
- (instancetype)initWithRelation:(SKYRelation *)relation direction:(SKYRelationDirection)direction NS_DESIGNATED_INITIALIZER;

/**
 Sets or returns an array of emails to be used to discover users.
 
 The value in this property is used only if the discoveryMethod is set to SKYUserDiscoveryMethodEmail; otherwise, it is ignored.
 */
@property (nonatomic, copy) NSArray /* NSString */ *emails;

/**
 Sets or returns the relation object used to query for users.
 
 The value in this property is used only if the discoveryMethod is set to SKYUserDiscoveryMethodRelation; otherwise, it is ignored.
 */
@property (strong, nonatomic) SKYRelation *relation;

/**
 Sets or returns the relation direction used for query. Defaults to SKYRelationDirectionOutgoing.

 The value in this property is used only if the discoveryMethod is set to SKYUserDiscoveryMethodRelation or the relation assigned to this operation is directional (like follow); otherwise, it is ignored.
 */
@property (nonatomic, assign) SKYRelationDirection relationDirection;

/**
 The method used to discover users. Assigned at creation time. (read-only)
 */
@property (nonatomic, readonly, assign) SKYUserDiscoveryMethod discoveryMethod;

/**
 Sets or returns a block to be called when a user fetch operation completes for
 a <SKYUser>.

 This block is not called when the entire operation results in an error.
 */
@property(nonatomic, copy) void (^perUserCompletionBlock)(SKYUser *user);

/**
 Sets or returns a block to be called when the entire operation completes. If
 the entire operation results in an error, the <NSError> will be specified.
 
 This block reports an error with code SKYErrorPartialFailure if the operation disocvers users by emails and no users can be found by some of the emails. The userInfo dictionary of the error contains a SKYPartialEmailsNotFoundKey key, whose value is a NSArray object containing all emails that no users can be found.
 */
@property (nonatomic, copy) void (^queryUserCompletionBlock)(NSArray /* SKYUser */ *users, NSError *operationError);

@end
