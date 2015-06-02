//
//  ODDeleteRelationOperation.m
//  Pods
//
//  Created by Rick Mak on 18/5/15.
//
//

#import "ODRemoveRelationsOperation.h"

#import "ODDataSerialization.h"
#import "ODError.h"
#import "ODUserRecordID_Private.h"

@implementation ODRemoveRelationsOperation


- (instancetype)initWithType:(NSString *)relationType usersToRemove:(NSArray *)users
{
    if ((self = [super init])) {
        _relationType = relationType;
        _usersToRemove = users;
    }
    return self;
}

- (void)prepareForRequest
{
    NSMutableDictionary *payload = [@{
                                      @"name": self.relationType
                                      } mutableCopy];
    NSMutableArray *targets = [NSMutableArray array];
    for (ODUser *user in self.usersToRemove) {
        [targets addObject:user.username];
    }
    payload[@"targets"] = targets;
    self.request = [[ODRequest alloc] initWithAction:@"relation:delete" payload:payload];
    self.request.accessToken = self.container.currentAccessToken;
}

- (NSArray *)processResultArray:(NSArray *)result operationError:(NSError **)operationError
{
    NSMutableArray *deletedUserIDs = [NSMutableArray array];
    NSMutableDictionary *errorByUserID = [NSMutableDictionary dictionary];
    [result enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        ODUserRecordID *userRecordID = nil;
        NSError *error = nil;

        NSString *userID = obj[@"id"];
        NSString *objType = obj[@"type"];
        if ([objType isEqual:@"error"]) {
            NSMutableDictionary *userInfo = [ODDataSerialization userInfoWithErrorDictionary:obj[@"data"]];
            userInfo[NSLocalizedDescriptionKey] = @"An error occurred while deleting relation.";
            errorByUserID[userID] = [NSError errorWithDomain:ODOperationErrorDomain
                                                        code:0
                                                    userInfo:userInfo];
        } else if (userID.length) {
            userRecordID = [ODUserRecordID recordIDWithUsername:userID];
            [deletedUserIDs addObject:userRecordID];
        }

        if (userRecordID == nil && error == nil) {
            NSDictionary *info = @{
                                   ODErrorCodeKey: @104,
                                   ODErrorTypeKey: @"MalformedResponse",
                                   ODErrorMessageKey: @"Per-item response is malformed",
                                   };
            error = [NSError errorWithDomain:ODOperationErrorDomain
                                        code:0
                                    userInfo:info];
        }

        if (self.perUserCompletionBlock) {
            self.perUserCompletionBlock(userRecordID, error);
        }
    }];

    if (errorByUserID.count) {
        *operationError = [NSError errorWithDomain:ODOperationErrorDomain
                                              code:ODErrorPartialFailure
                                          userInfo:@{
                                                     ODPartialErrorsByItemIDKey: errorByUserID,
                                                     }];
    }
    return deletedUserIDs;
}

- (void)handleRequestError:(NSError *)error
{
    if (self.removeRelationsCompletionBlock) {
        self.removeRelationsCompletionBlock(nil, error);
    }
}

- (void)handleResponse:(NSDictionary *)response
{
    NSArray *result = response[@"result"];
    NSArray *userIDs = nil;
    NSError *error = nil;
    if ([result isKindOfClass:[NSArray class]]) {
        userIDs = [self processResultArray:result operationError:&error];
    } else {
        userIDs = [NSArray array];
        NSDictionary *userInfo = [self errorUserInfoWithLocalizedDescription:@"Server returned malformed result."
                                                             errorDictionary:nil];
        error = [NSError errorWithDomain:ODOperationErrorDomain
                                    code:0
                                userInfo:userInfo];
    }
    if (self.removeRelationsCompletionBlock) {
        self.removeRelationsCompletionBlock(userIDs, error);
    }
}

@end
