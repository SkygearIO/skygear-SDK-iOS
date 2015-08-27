//
//  ODContainer.m
//  askq
//
//  Created by Kenji Pa on 19/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import "ODContainer.h"
#import "ODContainer_Private.h"
#import "ODDatabase_Private.h"
#import "ODOperation.h"
#import "ODPushOperation.h"
#import "ODUserLoginOperation.h"
#import "ODUserLogoutOperation.h"
#import "ODUserRecordID_Private.h"
#import "ODCreateUserOperation.h"
#import "ODRegisterDeviceOperation.h"
#import "ODUploadAssetOperation.h"
#import "ODLambdaOperation.h"

NSString *const ODContainerRequestBaseURL = @"http://localhost:5000/v1";
NSString *const ODContainerPubsubBaseURL = @"ws://localhost:5000/pubsub";

NSString *const ODContainerDidChangeCurrentUserNotification = @"ODContainerDidChangeCurrentUserNotification";
NSString *const ODContainerDidRegisterDeviceNotification = @"ODContainerDidRegisterDeviceNotification";

@interface ODContainer ()

@property (nonatomic, readonly) NSOperationQueue *operationQueue;

@end

@implementation ODContainer {
    ODAccessToken *_accessToken;
    ODUserRecordID *_userRecordID;
    ODDatabase *_publicCloudDatabase;
    NSString *_APIKey;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _endPointAddress = [NSURL URLWithString:ODContainerRequestBaseURL];
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.name = @"ODContainerOperationQueue";
        _publicCloudDatabase = [[ODDatabase alloc] initWithContainer:self];
        _publicCloudDatabase.databaseID = @"_public";
        _privateCloudDatabase = [[ODDatabase alloc] initWithContainer:self];
        _privateCloudDatabase.databaseID = @"_private";
        _APIKey = nil;
        NSURL *pubsubEndPoint = [NSURL URLWithString:ODContainerPubsubBaseURL];
        _pubsubClient = [[ODPubsub alloc] initWithEndPoint:pubsubEndPoint];
        
        [self loadAccessCurrentUserRecordIDAndAccessToken];
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

- (NSString *)registeredDeviceID
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"ODContainerDeviceID"];
}

/**
 Configurate the End-Point IP:PORT, no scheme is required. i.e. no http://
 */
- (void)configAddress:(NSString *)address {
    NSString *url = [NSString stringWithFormat:@"http://%@/", address];
    _endPointAddress = [NSURL URLWithString:url];
    NSString *pubsubUrl = [NSString stringWithFormat:@"ws://%@/pubsub", address];
    _pubsubClient.endPointAddress = [NSURL URLWithString:pubsubUrl];
}

- (void)configureWithAPIKey:(NSString *)APIKey
{
    if (APIKey != nil && ![APIKey isKindOfClass:[NSString class]]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"APIKey must be a subclass of NSString. %@ given.", NSStringFromClass([APIKey class])]
                                     userInfo:nil];
    }
    [self willChangeValueForKey:@"applicationIdentifier"];
    _APIKey = [APIKey copy];
    [self didChangeValueForKey:@"applicationIdentifier"];
}

- (void)addOperation:(ODOperation *)operation {
    operation.container = self;
    [self.operationQueue addOperation:operation];
}

- (ODAccessToken *)currentAccessToken
{
    return _accessToken;
}

- (void)loadAccessCurrentUserRecordIDAndAccessToken
{
    NSString *userRecordName = [[NSUserDefaults standardUserDefaults] objectForKey:@"ODContainerCurrentUserRecordID"];
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"ODContainerAccessToken"];
    if (userRecordName && accessToken) {
        _userRecordID = [ODUserRecordID recordIDWithUsername:userRecordName];
        _accessToken = [[ODAccessToken alloc] initWithTokenString:accessToken];
    }
}

- (void)updateWithUserRecordID:(ODUserRecordID *)userRecord accessToken:(ODAccessToken *)accessToken
{
    BOOL userRecordIDChanged = !([_userRecordID isEqual:userRecord] || (_userRecordID == nil && userRecord == nil));
    _userRecordID = userRecord;
    _accessToken = accessToken;
    
    if (userRecord && accessToken) {
        [[NSUserDefaults standardUserDefaults] setObject:userRecord.recordName forKey:@"ODContainerCurrentUserRecordID"];
        [[NSUserDefaults standardUserDefaults] setObject:accessToken.tokenString forKey:@"ODContainerAccessToken"];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ODContainerCurrentUserRecordID"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ODContainerAccessToken"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (userRecordIDChanged) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ODContainerDidChangeCurrentUserNotification
                                                            object:self
                                                          userInfo:nil];
    }
}

- (void)setAuthenticationErrorHandler:(void(^)(ODContainer *container, ODAccessToken *token, NSError *error))authErrorHandler
{
    _authErrorHandler = authErrorHandler;
}

- (void)signupUserWithUsername:(NSString *)username password:(NSString *)password completionHandler:(ODContainerUserOperationActionCompletion)completionHandler {
    ODCreateUserOperation *operation = [ODCreateUserOperation operationWithEmail:username password:password];
    operation.container = self;
    
    __weak typeof(self) weakSelf = self;
    operation.createCompletionBlock = ^(ODUserRecordID *recordID, ODAccessToken *accessToken, NSError *error) {
        if (!error) {
            [weakSelf updateWithUserRecordID:recordID accessToken:accessToken];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(recordID, error);
        });
    };
    
    [_operationQueue addOperation:operation];
}

- (void)signupUserAnonymouslyWithCompletionHandler:(ODContainerUserOperationActionCompletion)completionHandler
{
    ODCreateUserOperation *operation = [ODCreateUserOperation operationWithAnonymousUserAndPassword:@"CHANGEME"];
    
    __weak typeof(self) weakSelf = self;
    operation.createCompletionBlock = ^(ODUserRecordID *recordID, ODAccessToken *accessToken, NSError *error) {
        if (!error) {
            [weakSelf updateWithUserRecordID:recordID accessToken:accessToken];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(recordID, error);
        });
    };
    
    [self addOperation:operation];
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
    
    [_operationQueue addOperation:operation];
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
    
    [_operationQueue addOperation:operation];
}

- (void)registerRemoteNotificationDeviceToken:(NSData *)deviceToken
                             existingDeviceID:(NSString *)existingDeviceID
                            completionHandler:(void(^)(NSString *, NSError *))completionHandler
{
    ODRegisterDeviceOperation *op = [[ODRegisterDeviceOperation alloc] initWithDeviceToken:deviceToken];
    op.deviceID = existingDeviceID;
    op.registerCompletionBlock = ^(NSString *deviceID, NSError *error){
        BOOL willRetry = NO;
        if (error) {
            // If the device ID is not recognized by the server,
            // we should retry the request without the device ID.
            // Presumably the server will generate a new device ID.
            BOOL isNotFound = YES; // FIXME
            if (isNotFound && existingDeviceID) {
                [self registerRemoteNotificationDeviceToken:deviceToken
                                           existingDeviceID:nil
                                          completionHandler:completionHandler];
                willRetry = YES;
            }
        }
        
        if (!willRetry) {
            if (completionHandler) {
                completionHandler(deviceID, error);
            }
        }
    };
    [self addOperation:op];
}


- (void)registerRemoteNotificationDeviceToken:(NSData *)deviceToken completionHandler:(void(^)(NSString *, NSError *))completionHandler
{

    NSString *existingDeviceID = [self registeredDeviceID];
    [self registerRemoteNotificationDeviceToken:deviceToken
                               existingDeviceID:existingDeviceID
                              completionHandler:^(NSString *deviceID, NSError *error) {
                                  if (deviceID) {
                                      [[NSUserDefaults standardUserDefaults] setObject:deviceID
                                                                                forKey:@"ODContainerDeviceID"];
                                      [[NSUserDefaults standardUserDefaults] synchronize];
                                  }
                                  
                                  if (completionHandler) {
                                      completionHandler(deviceID, error);
                                  }
                                  
                                  [[NSNotificationCenter defaultCenter] postNotificationName:ODContainerDidRegisterDeviceNotification object:self];
                              }];
}

- (void)uploadAsset:(ODAsset *)asset completionHandler:(void(^)(ODAsset *, NSError*))completionHandler
{
    ODUploadAssetOperation *operation = [ODUploadAssetOperation operationWithAsset:asset];
    operation.uploadAssetCompletionBlock = completionHandler;
    [self addOperation:operation];
}

- (NSString *)APIKey
{
    if (!_APIKey) {
        NSLog(@"Warning: Container is not configured with an API key. Please call -[%@ %@].",
              NSStringFromClass([ODContainer class]),
              NSStringFromSelector(@selector(configureWithAPIKey:)));
        
        // TODO: This warning and early return should be removed when all apps are modified to call -configureWithAPIKey:.
        NSLog(@"Warning: A placeholder string is returned as an API key instead. This workaround will be removed in the future and ODOperation is required to check for its existence.");
        return @"PLACEHOLDER_API_KEY";
    }
    return _APIKey;
}

- (void)callLambda:(NSString *)action completionHandler:(void (^)(NSDictionary *, NSError *))completionHandler
{
    [self callLambda:action arguments:nil completionHandler:completionHandler];
}

- (void)callLambda:(NSString *)action arguments:(NSArray *)arguments completionHandler:(void (^)(NSDictionary *, NSError *))completionHandler
{
    arguments = arguments ? arguments : @[];
    ODLambdaOperation *operation = [[ODLambdaOperation alloc] initWithAction:action
                                                              arrayArguments:arguments];
    
    operation.lambdaCompletionBlock = ^(NSDictionary *result, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionHandler) {
                completionHandler(result, error);
            }
        });
    };
    
    [self addOperation:operation];
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
