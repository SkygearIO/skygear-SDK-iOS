//
//  SKYAuthContainer+ForgotPassword.m
//  SKYKit
//
//  Copyright 2017 Oursky Ltd.
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

#import "SKYAuthContainer+ForgotPassword.h"
#import "SKYAuthContainer_Private.h"

@implementation SKYAuthContainer (ForgotPassword)

- (void)forgotPasswordWithEmail:(NSString *)emailAddress
              completionHandler:(void (^)(NSDictionary *, NSError *))completionHandler
{
    [[self container] callLambda:@"user:forgot-password"
                       arguments:@[ emailAddress ]
               completionHandler:completionHandler];
}

- (void)resetPasswordWithUserID:(NSString *)userID
                           code:(NSString *)code
                       expireAt:(long)expireAt
                       password:(NSString *)password
              completionHandler:(void (^)(NSDictionary *, NSError *))completionHandler
{
    [[self container] callLambda:@"user:reset-password"
                       arguments:@[ userID, code, [NSNumber numberWithLong:expireAt], password ]
               completionHandler:completionHandler];
}

- (void)verifyUserWithCode:(NSString *)code
                completion:(SKYContainerUserOperationActionCompletion _Nullable)completionBlock
{
    SKYLambdaOperation *operation = [[SKYLambdaOperation alloc] initWithAction:@"user:verify_code"
                                                           dictionaryArguments:@{@"code" : code}];

    operation.lambdaCompletionBlock = ^(NSDictionary *result, NSError *error) {
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(nil, error);
                }
            });
            return;
        }

        // When sucessfully verifying user data, the user data should have changed. Call whoami to
        // refresh the current user record.
        [self getWhoAmIWithCompletionHandler:completionBlock];
    };

    [self.container addOperation:operation];
}

- (void)requestVerification:(NSString *)recordKey completion:(void (^)(NSError *))completionBlock
{
    SKYLambdaOperation *operation =
        [[SKYLambdaOperation alloc] initWithAction:@"user:verify_request"
                               dictionaryArguments:@{@"record_key" : recordKey}];

    operation.lambdaCompletionBlock = ^(NSDictionary *result, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(error);
            }
        });
    };

    [self.container addOperation:operation];
}

@end
