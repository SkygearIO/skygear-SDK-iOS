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

@implementation ODAddRelationsOperation

- (instancetype)initWithType:(NSString *)relationType andUsersToRelated:(NSArray *)users
{
    if ((self = [super init])) {
        _relationType = relationType;
        _usersToRelate = users;
    }
    return self;
}

- (void)prepareForRequest
{
    NSMutableDictionary *payload = [@{
                                     @"type": self.relationType
                                     } mutableCopy];
    NSMutableArray *targets = [NSMutableArray array];
    for (ODUser *user in self.usersToRelate) {
        [targets addObject:user.recordID.canonicalString];
    }
    payload[@"targets"] = targets;
    self.request = [[ODRequest alloc] initWithAction:@"relation:add" payload:payload];
    self.request.accessToken = self.container.currentAccessToken;
}

- (NSArray *)processResultArray:(NSArray *)result operationError:(NSError **)operationError
{
    NSMutableArray *savedUserIDs = [NSMutableArray array];
    NSMutableDictionary *errorByUserID = [NSMutableDictionary dictionary];
    [result enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSString *objType = obj[@"_type"];
        NSString *userID = obj[@"_id"];
        if ([objType isEqual:@"error"]) {
            NSMutableDictionary *userInfo = [ODDataSerialization userInfoWithErrorDictionary:obj];
            userInfo[NSLocalizedDescriptionKey] = @"An error occurred while adding relation.";
            errorByUserID[userID] = [NSError errorWithDomain:ODOperationErrorDomain
                                                        code:0
                                                    userInfo:userInfo];
        } else {
            // TODO: Error handling on add failed.
            ODUserRecordID *userRecordID = [[ODUserRecordID alloc] initWithCanonicalString:userID];
            [savedUserIDs addObject:userRecordID];
            if (self.perUserCompletionBlock) {
                self.perUserCompletionBlock(userRecordID, nil);
            }
            
        }
    }];
    if (errorByUserID.count) {
        *operationError = [NSError errorWithDomain:ODOperationErrorDomain
                                             code:ODErrorPartialFailure
                                         userInfo:@{
                                                    ODPartialErrorsByItemIDKey: errorByUserID,
                                                    }];
    }
    return savedUserIDs;
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
    NSArray *savedUserIDs = nil;
    NSError *error = nil;
    if ([result isKindOfClass:[NSArray class]]) {
        savedUserIDs = [self processResultArray:result operationError:&error];
    } else {
        savedUserIDs = [NSArray array];
        NSDictionary *userInfo = [self errorUserInfoWithLocalizedDescription:@"Server returned malformed result."
                                                             errorDictionary:nil];
        error = [NSError errorWithDomain:ODOperationErrorDomain
                                    code:0
                                userInfo:userInfo];
    }
    if (self.addRelationsCompletionBlock) {
        self.addRelationsCompletionBlock(savedUserIDs, error);
    }
}

@end
