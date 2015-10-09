//
//  SKYCreateUserOperation.m
//  Pods
//
//  Created by Patrick Cheung on 26/2/15.
//
//

#import "SKYCreateUserOperation.h"
#import "SKYRequest.h"
#import "SKYUserRecordID_Private.h"

@implementation SKYCreateUserOperation

+ (instancetype)operationWithEmail:(NSString *)email password:(NSString *)password
{
    return [[self alloc] initWithEmail:email password:password];
}

+ (instancetype)operationWithAnonymousUserAndPassword:(NSString *)password
{
    return [[self alloc] initWithAnonymousUserAndPassword:password];
}

- (instancetype)initWithEmail:(NSString *)email password:(NSString *)password
{
    if ((self = [super init])) {
        self.email = email;
        self.password = password;
        self.anonymousUser = NO;
    }
    return self;
}

- (instancetype)initWithAnonymousUserAndPassword:(NSString *)password
{
    if ((self = [super init])) {
        self.email = nil;
        self.password = nil;
        self.anonymousUser = YES;
    }
    return self;
}

- (void)prepareForRequest
{
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    if (!self.anonymousUser) {
        payload[@"user_id"] = self.email;
        payload[@"email"] = self.email;
        payload[@"password"] = self.password;
    }
    self.request = [[SKYRequest alloc] initWithAction:@"auth:signup"
                                             payload:payload];
    self.request.APIKey = self.container.APIKey;
}

- (void)operationWillStart
{
    [super operationWillStart];
    if (!self.container.APIKey) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"SKYContainer is not configured with an API key."
                                     userInfo:nil];
    }
}

- (void)setCreateCompletionBlock:(void (^)(SKYUserRecordID *, SKYAccessToken *, NSError *))createCompletionBlock
{
    if (createCompletionBlock) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            if (!weakSelf.error) {
                NSDictionary *response = weakSelf.response[@"result"];
                SKYUserRecordID *recordID = [SKYUserRecordID recordIDWithUsername:response[@"user_id"]];
                SKYAccessToken *accessToken = [[SKYAccessToken alloc] initWithTokenString:response[@"access_token"]];
                NSLog(@"User created with UserRecordID %@ and AccessToken %@", response[@"user_id"], response[@"access_token"]);
                createCompletionBlock(recordID, accessToken, nil);
            } else {
                createCompletionBlock(nil, nil, weakSelf.error);
            }
        };
    } else {
        self.completionBlock = nil;
    }
}



@end
