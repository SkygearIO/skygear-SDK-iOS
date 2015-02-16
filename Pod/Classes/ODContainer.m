//
//  ODContainer.m
//  askq
//
//  Created by Kenji Pa on 19/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODContainer.h"
#import "ODDatabase_Private.h"
#import "ODOperation.h"
#import "ODPushOperation.h"
#import "ODContainer_Private.h"
#import "ODUserLoginOperation.h"
#import "ODUserLogoutOperation.h"

NSString *const ODContainerRequestBaseURL = @"http://localhost:5000/v1";

@interface ODContainer ()

@property (nonatomic, readonly) NSOperationQueue *operationQueue;

@end

@implementation ODContainer {
    ODAccessToken *_accessToken;
    ODUserRecordID *_userRecordID;
    AFHTTPRequestOperationManager *_requestManager;
    ODDatabase *_publicCloudDatabase;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.name = @"ODContainerOperationQueue";
        _publicCloudDatabase = [[ODDatabase alloc] initPrivately];
    }
    return self;
}

+ (ODContainer *)defaultContainer {
    static dispatch_once_t onceToken;
    static ODContainer *ODContainerDefaultInstance;
    dispatch_once(&onceToken, ^{
        ODContainerDefaultInstance = [[ODContainer alloc] init];
    });
    return ODContainerDefaultInstance;
}

- (ODDatabase *)publicCloudDatabase {
    return _publicCloudDatabase;
}

- (ODUserRecordID *)currentUserRecordID {
    return _userRecordID;
}

- (void)addOperation:(ODOperation *)operation {
    [self.operationQueue addOperation:operation];
}

- (ODAccessToken *)currentAccessToken
{
    return _accessToken;
}

- (AFHTTPRequestOperationManager *)requestManager {
    if (!_requestManager) {
        _requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:ODContainerRequestBaseURL]];
        _requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return _requestManager;
}

- (void)updateWithUserRecordID:(ODUserRecordID *)userRecord accessToken:(ODAccessToken *)accessToken
{
    _userRecordID = userRecord;
    _accessToken = accessToken;
}

- (void)signupUserWithUsername:(NSString *)username password:(NSString *)password completionHandler:(ODContainerUserOperationActionCompletion)completionHandler {
    ODUserLoginOperation *operation = [[ODUserLoginOperation alloc] initWithEmail:username password:password];
    operation.createNewUser = YES;
    operation.container = self;
    
    __weak typeof(self) weakSelf = self;
    operation.loginCompletionBlock = ^(ODUserRecordID *recordID, ODAccessToken *accessToken, NSError *error) {
        if (!error) {
            [weakSelf updateWithUserRecordID:recordID accessToken:accessToken];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(recordID, error);
        });
    };
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

- (void)loginUserWithUsername:(NSString *)username password:(NSString *)password completionHandler:(ODContainerUserOperationActionCompletion)completionHandler {
    
    ODUserLoginOperation *operation = [[ODUserLoginOperation alloc] initWithEmail:username password:password];
    operation.container = self;
    
    __weak typeof(self) weakSelf = self;
    operation.loginCompletionBlock = ^(ODUserRecordID *recordID, ODAccessToken *accessToken, NSError *error) {
        if (!error) {
            [weakSelf updateWithUserRecordID:recordID accessToken:accessToken];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(recordID, error);
        });
    };
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

- (void)logoutUserWithcompletionHandler:(ODContainerUserOperationActionCompletion)completionHandler
{
    ODUserLogoutOperation *operation = [[ODUserLogoutOperation alloc] init];
    operation.container = self;
    
    __weak typeof(self) weakSelf = self;
    operation.logoutCompletionBlock = ^(NSError *error) {
        if (!error) {
            [weakSelf updateWithUserRecordID:nil accessToken:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(nil, error);
        });
    };
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

# pragma mark - ODPushOperation

- (void)pushToUserRecordID:(ODUserRecordID *)userRecordID alertBody:(NSString *)alertBody {
    ODPushOperation *pushOperation = [[ODPushOperation alloc] initWithUserRecordIDs:@[userRecordID] alertBody:alertBody];
    [self addOperation:pushOperation];
}

- (void)pushToUserRecordIDs:(NSArray *)userRecordIDs alertBody:(NSString *)alertBody {
    ODPushOperation *pushOperation = [[ODPushOperation alloc] initWithUserRecordIDs:userRecordIDs alertBody:alertBody];
    [self addOperation:pushOperation];
}

- (void)pushToUserRecordID:(ODUserRecordID *)userRecordID alertLocalizationKey:(NSString *)alertLocalizationKey alertLocalizationArgs:(NSArray *)alertLocalizationArgs {
    ODPushOperation *pushOperation = [[ODPushOperation alloc] initWithUserRecordIDs:@[userRecordID] alertLocalizationKey:alertLocalizationKey alertLocalizationArgs:alertLocalizationArgs];
    [self addOperation:pushOperation];
}

- (void)pushToUserRecordIDs:(NSArray *)userRecordIDs alertLocalizationKey:(NSString *)alertLocalizationKey alertLocalizationArgs:(NSArray *)alertLocalizationArgs {
    ODPushOperation *pushOperation = [[ODPushOperation alloc] initWithUserRecordIDs:userRecordIDs alertLocalizationKey:alertLocalizationKey alertLocalizationArgs:alertLocalizationArgs];
    [self addOperation:pushOperation];
}

@end
