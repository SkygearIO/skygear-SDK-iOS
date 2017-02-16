//
//  SKYLogoutUserOperation.h
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

#import "SKYOperation.h"

/**
 <SKYLogoutUserOperation> is a subclass of <SKYDatabaseOperation> that implements ends a user login
 session in
 container. Use this to log out the currently logged in user of an <SKYContainer>.
 */
@interface SKYLogoutUserOperation : SKYOperation

/**
 Sets or returns block to be called when the logout operation completes. If an error occurred, the
 error
 will be specified.
 */
@property (nonatomic, copy) void (^logoutCompletionBlock)(NSError *error);

@end
