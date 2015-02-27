//
//  ODContainer.h
//  askq
//
//  Created by Kenji Pa on 19/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ODDatabase.h"
#import "ODAccessToken.h"

@class ODUserRecordID;
@class ODOperation;

// keep it in sync with ODUserOperationActionCompletion
typedef void(^ODContainerUserOperationActionCompletion)(ODUserRecordID *user, NSError *error);

@interface ODContainer : NSObject

// seems we need a way to authenticate app
- (instancetype)initWithAddress:(NSString *)address;
+ (ODContainer *)defaultContainer;

@property (nonatomic, nonatomic) NSURL *endPointAddress;

@property (nonatomic, readonly) ODDatabase *publicCloudDatabase;
@property (nonatomic, readonly) ODDatabase *privateCloudDatabase;

@property (nonatomic, readonly) NSString *containerIdentifier;

@property (nonatomic, readonly) ODUserRecordID *currentUserRecordID;
@property (nonatomic, readonly) ODAccessToken *currentAccessToken;

- (void)addOperation:(ODOperation *)operation;

- (void)signupUserWithUsername:(NSString *)username password:(NSString *)password completionHandler:(ODContainerUserOperationActionCompletion)completionHandler;
- (void)updateWithUserRecordID:(ODUserRecordID *)userRecord accessToken:(ODAccessToken *)accessToken;

/**
 Creates an anonymous user account and log in as the created user.
 
 Use this to create a user that is not associated with an email address. This is a convenient method for
 <ODCreateUserOperation>.
 */
- (void)signupUserAnonymouslyWithCompletionHandler:(ODContainerUserOperationActionCompletion)completionHandler;
- (void)loginUserWithUsername:(NSString *)username password:(NSString *)password completionHandler:(ODContainerUserOperationActionCompletion)completionHandler;
- (void)logoutUserWithcompletionHandler:(ODContainerUserOperationActionCompletion)completionHandler;

@end

@interface ODContainer (ODPushOperation)

- (void)pushToUserRecordID:(ODUserRecordID *)userRecordID alertBody:(NSString *)alertBody;
- (void)pushToUserRecordIDs:(NSArray *)userRecordIDs alertBody:(NSString *)alertBody;

- (void)pushToUserRecordID:(ODUserRecordID *)userRecordID alertLocalizationKey:(NSString *)alertLocalizationKey alertLocalizationArgs:(NSArray *)alertLocalizationArgs;
- (void)pushToUserRecordIDs:(NSArray *)userRecordIDs alertLocalizationKey:(NSString *)alertLocalizationKey alertLocalizationArgs:(NSArray *)alertLocalizationArgs;

@end
