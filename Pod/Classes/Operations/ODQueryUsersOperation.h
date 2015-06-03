//
//  ODDiscoverUserOperation.h
//  Pods
//
//  Created by Kenji Pa on 29/5/15.
//
//

#import "ODOperation.h"

#import "ODRelation.h"

typedef enum : NSUInteger {
    ODUserDiscoveryMethodEmail = 0,
    ODUserDiscoveryMethodRelation = 1,
} ODUserDiscoveryMethod;

typedef enum : NSInteger {
    ODRelationDirectionActive,
    ODRelationDirectionPassive,
    ODRelationDirectionMutual
} ODRelationDirection;

/**
 <ODQueryUsersOperation> is a subclass of <ODOperation> that implements user query
 in Ourd. Use this operation to query other user in the same application.
 */
@interface ODQueryUsersOperation : ODOperation

/**
 Returns an operation object that discovers users by their email.
 */
+ (instancetype)discoverUsersOperationByEmails:(NSArray /* NSString */ *)emails;

/**
 Returns an operation object that queries users by their relation to the current user.
 */
+ (instancetype)queryUsersOperationByRelation:(ODRelation *)relation;

/**
 Returns an operation object that queries users by their relation to the current user with the specified direction.
 */
+ (instancetype)queryUsersOperationByRelation:(ODRelation *)relation direction:(ODRelationDirection)direction;

/**
 Initializes and returns a email-based user discovery operation object.
 
 @param emails An array of emails to be used for user discovery.
 */
- (instancetype)initWithEmails:(NSArray /* NSString */ *)emails NS_DESIGNATED_INITIALIZER;

/**
 Initializes and returns a relation-based user query operation object.

 @param relation The relation object to be used for user discovery.
 */
- (instancetype)initWithRelation:(ODRelation *)relation;

/**
 Initializes and returns a relation-based user query operation object with relation direction specified.

 @param relation The relation object to be used for user discovery.
 */
- (instancetype)initWithRelation:(ODRelation *)relation direction:(ODRelationDirection)direction NS_DESIGNATED_INITIALIZER;

/**
 Sets or returns an array of emails to be used to discover users.
 
 The value in this property is used only if the discoveryMethod is set to ODUserDiscoveryMethodEmail; otherwise, it is ignored.
 */
@property (nonatomic, copy) NSArray /* NSString */ *emails;

/**
 Sets or returns the relation object used to query for users.
 
 The value in this property is used only if the discoveryMethod is set to ODUserDiscoveryMethodRelation; otherwise, it is ignored.
 */
@property (strong, nonatomic) ODRelation *relation;

/**
 Sets or returns the relation direction used for query. Defaults to ODRelationDirectionOutgoing.

 The value in this property is used only if the discoveryMethod is set to ODUserDiscoveryMethodRelation or the relation assigned to this operation is directional (like follow); otherwise, it is ignored.
 */
@property (nonatomic, assign) ODRelationDirection relationDirection;

/**
 The method used to discover users. Assigned at creation time. (read-only)
 */
@property (nonatomic, readonly, assign) ODUserDiscoveryMethod discoveryMethod;

/**
 Sets or returns a block to be called when a user fetch operation completes for
 a <ODUser>.

 This block is not called when the entire operation results in an error.
 */
@property(nonatomic, copy) void (^perUserCompletionBlock)(ODUser *user);

/**
 Sets or returns a block to be called when the entire operation completes. If
 the entire operation results in an error, the <NSError> will be specified.
 
 This block reports an error with code ODErrorPartialFailure if the operation disocvers users by emails and no users can be found by some of the emails. The userInfo dictionary of the error contains a ODPartialEmailsNotFoundKey key, whose value is a NSArray object containing all emails that no users can be found.
 */
@property (nonatomic, copy) void (^discoverUserCompletionBlock)(NSArray /* ODUser */ *users, NSError *operationError);

@end
