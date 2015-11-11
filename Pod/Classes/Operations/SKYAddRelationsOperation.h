//
//  SKYAddRelationOperation.h
//  Pods
//
//  Created by Rick Mak on 18/5/15.
//
//

#import "SKYOperation.h"

@interface SKYAddRelationsOperation : SKYOperation

/**
 Instantiates an instance of <SKYAddRelationsOperation> with a list of user to be related with
 current user.

 @param records An array of users to be related.
 */
- (instancetype)initWithType:(NSString *)relationType usersToRelated:(NSArray /* SKYUser */ *)users;

/**
 Creates and returns an instance of <SKYAddRelationsOperation> with a list of user to be related
 with current user.

 @param records An array of users to be related.
 */
+ (instancetype)operationWithType:(NSString *)relationType
                   usersToRelated:(NSArray /* SKYUser */ *)users;

/**
 Type of the relation, default provide `follow` and `friend`.
 */
@property (nonatomic, copy) NSString *relationType;

/**
 Sets or returns an array of users to be related.
 */
@property (nonatomic, copy) NSArray /* SKYUser */ *usersToRelate;

/**
 Sets or returns a block to be called when the save operation for individual record is completed.
 If an error occurred during the save, the <NSError> will be specified.
 */
@property (nonatomic, copy) void (^perUserCompletionBlock)(SKYUserRecordID *userID, NSError *error);

/**
 Sets or returns a block to be called when the entire operation completes. If the entire operation
 results in an error, the <NSError> will be specified.
 */
@property (nonatomic, copy) void (^addRelationsCompletionBlock)
    (NSArray /* SKYUserRecordID */ *savedUserIDs, NSError *operationError);

@end
