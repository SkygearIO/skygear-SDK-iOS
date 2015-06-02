//
//  ODAddRelationOperation.m
//  Pods
//
//  Created by Rick Mak on 18/5/15.
//
//

#import "ODAddRelationsOperation.h"

#import "ODDataSerialization.h"
#import "ODError.h"
#import "ODUserRecordID_Private.h"

@implementation ODAddRelationsOperation

- (instancetype)initWithType:(NSString *)relationType usersToRelated:(NSArray *)users
{
    if ((self = [super init])) {
        _relationType = relationType;
        _usersToRelate = users;
    }
    return self;
}

- (NSArray /* NSString */ *)userStringIDs
{
    NSMutableArray *ids = [NSMutableArray arrayWithCapacity:self.usersToRelate.count];
    for (ODUser *user in self.usersToRelate) {
        [ids addObject:user.username];
    }
    return ids;
}

- (void)prepareForRequest
{
    NSMutableDictionary *payload = [@{
                                     @"name": self.relationType
                                     } mutableCopy];
    NSMutableArray *targets = [NSMutableArray array];
    for (ODUser *user in self.usersToRelate) {
        [targets addObject:user.username];
    }
    payload[@"targets"] = targets;
    self.request = [[ODRequest alloc] initWithAction:@"relation:add" payload:payload];
    self.request.accessToken = self.container.currentAccessToken;
}

- (void)handleRequestError:(NSError *)error
{
    if (self.addRelationsCompletionBlock) {
        self.addRelationsCompletionBlock(nil, error);
    }
}

- (void)handleResponse:(NSDictionary *)response
{
    NSArray *result = response[@"result"];
    if (![result isKindOfClass:[NSArray class]]) {
        NSDictionary *userInfo = [self errorUserInfoWithLocalizedDescription:@"Server returned malformed result."
                                                             errorDictionary:nil];
        NSError *error = [NSError errorWithDomain:ODOperationErrorDomain
                                    code:0
                                userInfo:userInfo];
        if (self.addRelationsCompletionBlock) {
            self.addRelationsCompletionBlock(nil, error);
        }
        return;
    }

    NSDictionary *itemsByID = [self.class itemsByIDFromResult:result];

    NSMutableArray *savedUsers = [NSMutableArray arrayWithCapacity:itemsByID.count];
    NSMutableDictionary *errorsByStringUserID = [NSMutableDictionary dictionary];
    for (ODUser *user in self.usersToRelate) {
        NSDictionary *itemDict = itemsByID[user.username];

        ODUserRecordID *returnedUserID = nil;
        NSError *error = nil;

        if (!itemDict.count) {
            NSDictionary *info = @{
                                   ODErrorCodeKey: @104,
                                   ODErrorTypeKey: @"ResourceNotFound",
                                   ODErrorMessageKey: @"User missing in response",
                                   ODErrorInfoKey: @{@"id": user.username},
                                   };
            error = [NSError errorWithDomain:ODOperationErrorDomain
                                        code:0
                                    userInfo:info];
        } else {
            NSString *itemType = itemDict[@"type"];
            if ([itemType isEqualToString:@"error"]) {
                NSDictionary *info = [ODDataSerialization userInfoWithErrorDictionary:itemDict[@"data"]];
                error = [NSError errorWithDomain:ODOperationErrorDomain
                                            code:0
                                        userInfo:info];
            } else {
                returnedUserID = [ODUserRecordID recordIDWithUsername:user.username];
                if (returnedUserID == nil) {
                    NSDictionary *info = [self errorUserInfoWithLocalizedDescription:@"User does not conform with expected format." errorDictionary:nil];
                    error = [NSError errorWithDomain:ODOperationErrorDomain
                                                code:0
                                            userInfo:info];
                }
            }
        }

        NSAssert(
                 (returnedUserID == nil && error != nil) ||
                 (returnedUserID != nil && error == nil),
                 @"either one from user and error is not nil");

        if (self.perUserCompletionBlock) {
            self.perUserCompletionBlock(returnedUserID, error);
        }

        if (returnedUserID != nil) {
            [savedUsers addObject:returnedUserID];
        } else {
            errorsByStringUserID[user.username] = error;
        }
    }

    if (self.addRelationsCompletionBlock) {
        NSError *operationError = nil;
        if (errorsByStringUserID.count) {
            operationError = [NSError errorWithDomain:ODOperationErrorDomain
                                                 code:ODErrorPartialFailure
                                             userInfo:@{
                                                        ODPartialErrorsByItemIDKey: errorsByStringUserID,
                                                        }];
        }

        self.addRelationsCompletionBlock(savedUsers, operationError);
    }
}

+ (NSDictionary *)itemsByIDFromResult:(NSArray *)result
{
    NSMutableDictionary *itemsByID = [NSMutableDictionary dictionaryWithCapacity:result.count];
    for (NSDictionary *itemDict in result) {
        NSString *itemID = itemDict[@"id"];
        itemsByID[itemID] = itemDict;
    }
    return itemsByID;
}

@end
