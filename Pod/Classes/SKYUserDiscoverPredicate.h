//
//  SKYUserDiscoverPredicate.h
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

#import <Foundation/Foundation.h>

/**
 * The <SKYUserDiscoverPredicate> specifies a condition to search for users
 * having the specified user data.
 */
@interface SKYUserDiscoverPredicate : NSPredicate

/**
 * Returns user email in predicate.
 */
@property (nonatomic, readonly) NSArray<NSString *> *emails;

/**
 * Returns username in predicate.
 */
@property (nonatomic, readonly) NSArray<NSString *> *usernames;

/**
 * Returns an instance of <SKYDiscoverPredicate> for searching user by emails and usernames.
 */
+ (instancetype)predicateWithEmails:(NSArray<NSString *> *)emails
                          usernames:(NSArray<NSString *> *)usernames;

/**
 * Returns an instance of <SKYDiscoverPredicate> for searching user by emails.
 */
+ (instancetype)predicateWithEmails:(NSArray<NSString *> *)emails;

/**
 * Returns an instance of <SKYDiscoverPredicate> for searching user by usernames.
 */
+ (instancetype)predicateWithUsernames:(NSArray<NSString *> *)usernames;

@end
