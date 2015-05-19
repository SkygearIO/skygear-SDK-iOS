//
//  ODDeleteRelationOperation.h
//  Pods
//
//  Created by Rick Mak on 18/5/15.
//
//

#import "ODOperation.h"

@interface ODDeleteRelationsOperation : ODOperation


/**
 Instantiates an instance of <ODDeleteRelationsOperation> with a list of user to be related with current user.
 */
- (instancetype)initWithType:(NSString *)relationType andUsersToDelete:(NSArray *)users;

/**
 Type of the relation, default provide `follow` and `friend`.
 */
@property (nonatomic, copy) NSString *relationType;

/**
 Sets or returns an array of users to be delete on the specified related.
 */
@property (nonatomic, copy) NSArray *usersToDelete;


/**
 Sets or returns a block to be called when the save operation for individual record is completed.
 If an error occurred during the delete, the <NSError> will be specified.
 */
@property (nonatomic, copy) void (^perUserCompletionBlock)(ODUserRecordID *userID, NSError *error);

/**
 Sets or returns a block to be called when the entire operation completes. If the entire operation
 results in an error, the <NSError> will be specified.
 */
@property (nonatomic, copy) void (^deleteRelationsCompletionBlock)(NSArray *deletedUserIDs, NSError *operationError);

@end
