//
//  ODDiscoverUserOperation.h
//  Pods
//
//  Created by Kenji Pa on 29/5/15.
//
//

#import "ODOperation.h"

typedef enum : NSUInteger {
    ODUserDiscoveryMethodEmail = 0,
} ODUserDiscoveryMethod;

/**
 <ODDiscoverUsersOperation> is a subclass of <ODOperation> that implements user discovery
 in Ourd. Use this operation to discover other users in the same application.
 */
@interface ODDiscoverUsersOperation : ODOperation

/**
 Returns an operation object that discover users by their email.
 */
+ (instancetype)discoverUsersOperationByEmails:(NSArray /* NSString */ *)emails;

/**
 Initializes and returns a email-based user discovery operation object.
 
 @param emails An array of emails to be used for user discovery.
 */
- (instancetype)initWithEmails:(NSArray /* NSString */ *)emails;

/**
 Sets or returns an array of emails to be used to discover users.
 
 The value in this property is used only if the discoveryMethod is set to ODUserDiscoveryMethodEmail; otherwise, it is ignored.
 */
@property (nonatomic, copy) NSArray /* NSString */ *emails;

/**
 The method used to discover users. Assigned at creation time. (read-only)
 */
@property (nonatomic, readonly, assign) ODUserDiscoveryMethod discoveryMethod;

/**
 Sets or returns a block to be called when the entire operation completes. If
 the entire operation results in an error, the <NSError> will be specified.
 */
@property (nonatomic, copy) void (^discoverUserCompletionBlock)(NSArray /* ODUser */ *users, NSArray /* NSString */ *emailsNotFound, NSError *operationError);

@end
