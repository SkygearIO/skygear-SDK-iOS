//
//  SKYAuthContainer_Private.h
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

#import "SKYAuthContainer.h"

#import "SKYOperation.h"

@interface SKYAuthContainer ()

@property (nonatomic, weak) SKYContainer *container;

@property (nonatomic, copy, setter=setAuthenticationErrorHandler:) void (^authErrorHandler)
    (SKYContainer *container, SKYAccessToken *token, NSError *error);

- (instancetype)initWithContainer:(SKYContainer *)container;

/**
 Loads <NSString> and <SKYAccessToken> from persistent storage. Use this method to resume
 user's access credentials
 after application launch.

 This method is called when <SKYContainer> is `-init` is called. You should not call this method
 manually.
 */
- (void)loadCurrentUserAndAccessToken;

@end
