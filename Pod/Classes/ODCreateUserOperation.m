//
//  ODCreateUserOperation.m
//  Pods
//
//  Created by Patrick Cheung on 26/2/15.
//
//

#import "ODCreateUserOperation.h"
#import "ODRequest.h"
#import "ODUserRecordID_Private.h"

@implementation ODCreateUserOperation

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
        self.password = password;
        self.anonymousUser = YES;
    }
    return self;
}

- (void)prepareForRequest
{
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    if (!self.anonymousUser) {
        payload[@"email"] = self.email;
    }
    payload[@"password"] = self.password;
    self.request = [[ODRequest alloc] initWithAction:@"auth:signup"
                                             payload:payload];
}

- (void)setCreateCompletionBlock:(void (^)(ODUserRecordID *, ODAccessToken *, NSError *))createCompletionBlock
{
    if (createCompletionBlock) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            if (!weakSelf.error) {
                NSDictionary *response = weakSelf.response[@"result"];
                ODUserRecordID *recordID = [[ODUserRecordID alloc] initWithRecordName:response[@"user_id"]];
                ODAccessToken *accessToken = [[ODAccessToken alloc] initWithTokenString:response[@"access_token"]];
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
