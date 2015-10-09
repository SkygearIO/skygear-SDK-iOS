//
//  SKYDeleteRelationOperation.h
//  Pods
//
//  Created by Rick Mak on 18/5/15.
//
//

#import "SKYOperation.h"

@interface SKYRemoveRelationsOperation : SKYOperation


/**
 Instantiates an instance of <SKYDeleteRelationsOperation> with a list of user to be related with current user.
 */
- (instancetype)initWithType:(NSString *)relationType usersToRemove:(NSArray *)users;

/**
 Creates and returns an instance of <SKYDeleteRelationsOperation> with a list of user to be related with current user.
 */
+ (instancetype)operationWithType:(NSString *)relationType usersToRemove:(NSArray *)users;

/**
 Type of the relation, default provide `follow` and `friend`.
 */
@property (nonatomic, copy) NSString *relationType;

/**
 Sets or returns an array of users to be delete on the specified related.
 */
@property (nonatomic, copy) NSArray *usersToRemove;


/**
 Sets or returns a block to be called when the save operation for individual record is completed.
 If an error occurred during the delete, the <NSError> will be specified.
 */
@property (nonatomic, copy) void (^perUserCompletionBlock)(SKYUserRecordID *userID, NSError *error);

/**
 Sets or returns a block to be called when the entire operation completes. If the entire operation
 results in an error, the <NSError> will be specified.
 */
@property (nonatomic, copy) void (^removeRelationsCompletionBlock)(NSArray *deletedUserIDs, NSError *operationError);

@end
