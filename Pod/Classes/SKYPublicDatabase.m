//
//  SKYPublicDatabase.m
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

#import "SKYPublicDatabase.h"

#import "SKYAssignUserRoleOperation.h"
#import "SKYDefineAdminRolesOperation.h"
#import "SKYDefineCreationAccessOperation.h"
#import "SKYDefineDefaultAccessOperation.h"
#import "SKYFetchUserRoleOperation.h"
#import "SKYRevokeUserRoleOperation.h"
#import "SKYSetUserDefaultRoleOperation.h"

@implementation SKYPublicDatabase

- (void)defineAdminRoles:(NSArray<SKYRole *> *)roles
              completion:(void (^)(NSError *error))completionBlock
{
    SKYDefineAdminRolesOperation *operation =
        [SKYDefineAdminRolesOperation operationWithRoles:roles];

    operation.defineAdminRolesCompletionBlock = ^(NSArray<SKYRole *> *roles, NSError *error) {
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(error);
            });
        }
    };

    [self.container addOperation:operation];
}

- (void)setUserDefaultRole:(NSArray<SKYRole *> *)roles
                completion:(void (^)(NSError *error))completionBlock
{
    SKYSetUserDefaultRoleOperation *operation =
        [SKYSetUserDefaultRoleOperation operationWithRoles:roles];

    operation.setUserDefaultRoleCompletionBlock = ^(NSArray<SKYRole *> *roles, NSError *error) {
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(error);
            });
        }
    };

    [self.container addOperation:operation];
}

- (void)defineCreationAccessWithRecordType:(NSString *)recordType
                                     roles:(NSArray<SKYRole *> *)roles
                                completion:(void (^)(NSError *error))completionBlock
{
    SKYDefineCreationAccessOperation *operation =
        [SKYDefineCreationAccessOperation operationWithRecordType:recordType roles:roles];
    operation.defineCreationAccessCompletionBlock =
        ^(NSString *recordType, NSArray<SKYRole *> *roles, NSError *error) {
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(error);
                });
            }
        };

    [self.container addOperation:operation];
}

- (void)defineDefaultAccessWithRecordType:(NSString *)recordType
                                   access:(SKYAccessControl *)accessControl
                               completion:(void (^)(NSError *error))completionBlock
{
    SKYDefineDefaultAccessOperation *operation =
        [SKYDefineDefaultAccessOperation operationWithRecordType:recordType
                                                   accessControl:accessControl];

    operation.defineDefaultAccessCompletionBlock =
        ^(NSString *recordType, SKYAccessControl *accessControl, NSError *error) {
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(error);
                });
            }
        };

    [self.container addOperation:operation];
}

- (void)fetchRolesOfUsers:(NSArray<SKYRecord *> *)users
               completion:(void (^)(NSDictionary<NSString *, NSArray<SKYRole *> *> *,
                                    NSError *))completionBlock
{
    [self fetchRolesOfUsersWithUserIDs:[self getUserIDs:users]
                            completion:^(NSDictionary<NSString *, NSArray<NSString *> *> *userRoles,
                                         NSError *error) {
                                if (completionBlock) {
                                    if (error) {
                                        completionBlock(nil, error);
                                        return;
                                    }

                                    NSMutableDictionary<NSString *, NSArray<SKYRole *> *>
                                        *parsedUserRoles = [NSMutableDictionary dictionary];
                                    for (NSString *userID in userRoles) {
                                        NSMutableArray *roles = [NSMutableArray array];
                                        for (NSString *role in userRoles[userID]) {
                                            [roles addObject:[SKYRole roleWithName:role]];
                                        }
                                        [parsedUserRoles setObject:roles forKey:userID];
                                    }

                                    completionBlock(parsedUserRoles, nil);
                                }
                            }];
}

- (void)fetchRolesOfUsersWithUserIDs:(NSArray<NSString *> *)userIDs
                          completion:(void (^)(NSDictionary<NSString *, NSArray<NSString *> *> *,
                                               NSError *))completionBlock
{
    SKYFetchUserRoleOperation *operation = [SKYFetchUserRoleOperation operationWithUserIDs:userIDs];
    operation.fetchUserRoleCompletionBlock =
        ^(NSDictionary<NSString *, NSArray<NSString *> *> *userRoles, NSError *error) {
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(userRoles, error);
                });
            }
        };

    [self.container addOperation:operation];
}

- (void)assignRoles:(NSArray<SKYRole *> *)roles
            toUsers:(NSArray<SKYRecord *> *)users
         completion:(void (^)(NSError *error))completionBlock
{
    [self assignRolesWithNames:[self getRoleNames:roles]
                toUsersWithIDs:[self getUserIDs:users]
                    completion:completionBlock];
}

- (void)assignRolesWithNames:(NSArray<NSString *> *)roleNames
              toUsersWithIDs:(NSArray<NSString *> *)userIDs
                  completion:(void (^)(NSError *error))completionBlock
{
    SKYAssignUserRoleOperation *operation =
        [SKYAssignUserRoleOperation operationWithUserIDs:userIDs roleNames:roleNames];

    operation.assignUserRoleCompletionBlock = ^(NSArray<SKYRecord *> *users, NSError *error) {
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(error);
            });
        }
    };

    [self.container addOperation:operation];
}

- (void)revokeRoles:(NSArray<SKYRole *> *)roles
          fromUsers:(NSArray<SKYRecord *> *)users
         completion:(void (^)(NSError *error))completionBlock
{
    [self revokeRolesWithNames:[self getRoleNames:roles]
              fromUsersWihtIDs:[self getUserIDs:users]
                    completion:completionBlock];
}

- (void)revokeRolesWithNames:(NSArray<NSString *> *)roleNames
            fromUsersWihtIDs:(NSArray<NSString *> *)userIDs
                  completion:(void (^)(NSError *error))completionBlock
{
    SKYRevokeUserRoleOperation *operation =
        [SKYRevokeUserRoleOperation operationWithUserIDs:userIDs roleNames:roleNames];

    operation.revokeUserRoleCompletionBlock = ^(NSArray<NSString *> *userIDs, NSError *error) {
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(error);
            });
        }
    };

    [self.container addOperation:operation];
}

- (NSArray<NSString *> *)getUserIDs:(NSArray<SKYRecord *> *)users
{
    NSMutableArray<NSString *> *userIDs = [NSMutableArray arrayWithCapacity:users.count];
    for (SKYRecord *user in users) {
        if (![user.recordID.recordType isEqualToString:@"user"]) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"Record type should be user"
                                         userInfo:nil];
        }

        [userIDs addObject:user.recordID.recordName];
    }

    return userIDs;
}

- (NSArray<NSString *> *)getRoleNames:(NSArray<SKYRole *> *)roles
{
    NSMutableArray<NSString *> *roleNames = [NSMutableArray arrayWithCapacity:roles.count];
    for (SKYRole *role in roles) {
        [roleNames addObject:role.name];
    }

    return roleNames;
}

@end
