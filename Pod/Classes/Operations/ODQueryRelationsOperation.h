//
//  ODFetchRelationsOperation.h
//  Pods
//
//  Created by Rick Mak on 18/5/15.
//
//

#import "ODOperation.h"

/**
 <ODFetchRelationsOperation> is a subclass of <ODOperation> that implements
 fetching users by relation from Ourd.
 Use this to fetch a number of users by specifying the relation to current
 logged in user

 When the operation completes, the <fetchUsersCompletionBlock> will be called
 with all the fetched users, or an error will be returned stating the error.
 For each <ODUser>, the <perUserCompletionBlock> will be called with the fetched
 user or an error if one occurred.
 */
@interface ODQueryRelationsOperation : ODOperation

typedef enum : NSInteger {
    ODRelationDirectionActive,
    ODRelationDirectionPassive,
    ODRelationDirectionMutual
} ODRelationDirection;

/**
 Type of the relation, default provide `follow` and `friend`.
 */
@property (nonatomic, copy) NSString *relationType;
@property (nonatomic, assign) ODRelationDirection direction;

- (instancetype)initWithType:(NSString *)relationType direction:(ODRelationDirection)direction;

/**
 Sets or returns a block to be called when a user fetch operation completes for
 a <ODUser>.

 This block is not called when the entire operation results in an error.
 */
@property(nonatomic, copy) void (^perUserCompletionBlock)(ODUser *user);

/**
 Sets or returns a block to be called when the entire operation completes. The
 fetched users are specified in an <NSArray>. If an error occurred for the
 entire operation, an error will be specified.
 */
@property(nonatomic, copy) void (^queryUsersCompletionBlock)(NSArray *users, NSError *operationError);

@end
