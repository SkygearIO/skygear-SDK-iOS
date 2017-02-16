//
//  SKYAddRelationsOperation.h
//  SKYKit
//
//  Copyright 2015 Oursky Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
@property (nonatomic, copy) void (^perUserCompletionBlock)(NSString *userID, NSError *error);

/**
 Sets or returns a block to be called when the entire operation completes. If the entire operation
 results in an error, the <NSError> will be specified.
 */
@property (nonatomic, copy) void (^addRelationsCompletionBlock)
    (NSArray /* NSString */ *savedUserIDs, NSError *operationError);

@end
