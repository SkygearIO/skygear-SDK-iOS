//
//  ODUser.h
//  askq
//
//  Created by Kenji Pa on 27/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODRecord.h"

#import "ODUserRecordID.h"

@class ODFollowReference;
@class ODQueryCursor;
@class ODQueryOperation;

@interface ODUser : ODRecord

- (instancetype)initWithUserRecordID:(ODUserRecordID *)recordID;
- (instancetype)initWithUserRecordID:(ODUserRecordID *)recordID data:(NSDictionary *)data NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithRecordType:(NSString *)recordType NS_UNAVAILABLE;
- (instancetype)initWithRecordType:(NSString *)recordType name:(NSString *)recordName NS_UNAVAILABLE;
- (instancetype)initWithRecordType:(NSString *)recordType recordID:(ODRecordID *)recordId NS_UNAVAILABLE;
- (instancetype)initWithRecordType:(NSString *)recordType recordID:(ODRecordID *)recordId data:(NSDictionary *)data NS_UNAVAILABLE;
- (instancetype)initWithRecordType:(NSString *)recordType name:(NSString *)recordName data:(NSDictionary *)data NS_UNAVAILABLE;
- (instancetype)initWithRecordID:(ODRecordID *)recordId data:(NSDictionary *)data NS_UNAVAILABLE;

+ (instancetype)userWithUserRecordID:(ODUserRecordID *)recordID;
+ (instancetype)userWithUserRecordID:(ODUserRecordID *)recordID data:(NSDictionary *)data;

/**
 * The properties username, email, authData and isNew will be delegated to 
 * their corresponding methods on ODUserRecordID
 */
@property (nonatomic, readonly, copy) NSString *username;
@property (nonatomic, readonly, copy) NSString *email;
@property (nonatomic, readonly, copy) NSDictionary *authData;
@property (nonatomic, readonly, assign) BOOL isNew;

@property (nonatomic, readonly, copy) ODUserRecordID *recordID;

@end

@interface ODUser(ODFollowReference)

// delegate to [[self followReference] add:user]
- (void)follow:(ODUser *)user;
- (void)follow:(ODUser *)user withType:(NSString *)type;

// delegate to [[self followReference] remove:user]
- (void)unfollow:(ODUser *)user;
- (void)unfollow:(ODUser *)user withType:(NSString *)type;

- (ODFollowReference *)followReference;
- (ODFollowReference *)followReferenceOfType:(NSString *)followType;

- (ODQueryOperation *)followingQueryOperation;
- (ODQueryOperation *)followingQueryOperationWithRecordFetchedBlock:(void(^)(ODRecord *record))recordFetchedBlock
                                               queryCompletionBlock:(void(^)(ODQueryCursor *cursor, NSError *operationError))queryCompletionBlock;
- (ODQueryOperation *)followingQueryOperationOfType:(NSString *)followType;
- (ODQueryOperation *)followingQueryOperationOfType:(NSString *)followType
                                 recordFetchedBlock:(void(^)(ODRecord *record))recordFetchedBlock
                               queryCompletionBlock:(void(^)(ODQueryCursor *cursor, NSError *operationError))queryCompletionBlock;

- (ODQueryOperation *)followerQueryOperation;
- (ODQueryOperation *)followerQueryOperationWithRecordFetchedBlock:(void(^)(ODRecord *record))recordFetchedBlock
                                              queryCompletionBlock:(void(^)(ODQueryCursor *cursor, NSError *operationError))queryCompletionBlock;

- (ODQueryOperation *)followerQueryOperationOfType:(NSString *)followType;
- (ODQueryOperation *)followerQueryOperationOfType:(NSString *)followType
                                recordFetchedBlock:(void(^)(ODRecord *record))recordFetchedBlock
                              queryCompletionBlock:(void(^)(ODQueryCursor *cursor, NSError *operationError))queryCompletionBlock;;

- (ODQueryOperation *)mutualFollowerQueryOperation;
- (ODQueryOperation *)mutualFollowerQueryOperationWithRecordFetchedBlock:(void(^)(ODRecord *record))recordFetchedBlock
                                                    queryCompletionBlock:(void(^)(ODQueryCursor *cursor, NSError *operationError))queryCompletionBlock;

- (ODQueryOperation *)mutualFollowerQueryOperationOfType:(NSString *)followType;
- (ODQueryOperation *)mutualFollowerQueryOperationOfType:(NSString *)followType
                                      recordFetchedBlock:(void(^)(ODRecord *record))recordFetchedBlock
                                    queryCompletionBlock:(void(^)(ODQueryCursor *cursor, NSError *operationError))queryCompletionBlock;

@end
