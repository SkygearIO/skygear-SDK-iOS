//
//  SKYUserDiscoverPredicate.m
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

#import "SKYUserDiscoverPredicate.h"

@implementation SKYUserDiscoverPredicate

- (instancetype)init
{
    if (self == [super init]) {
    }
    return self;
}

+ (instancetype)predicateWithEmails:(NSArray<NSString *> *)emails
                          usernames:(NSArray<NSString *> *)usernames
{
    SKYUserDiscoverPredicate *p = [[SKYUserDiscoverPredicate alloc] init];
    p->_emails = [emails copy];
    if (![p->_emails isKindOfClass:[NSArray class]]) {
        p->_emails = [NSArray array];
    }
    p->_usernames = [usernames copy];
    if (![p->_usernames isKindOfClass:[NSArray class]]) {
        p->_usernames = [NSArray array];
    }
    return p;
}

+ (instancetype)predicateWithEmails:(NSArray<NSString *> *)emails
{
    return [SKYUserDiscoverPredicate predicateWithEmails:emails usernames:nil];
}

+ (instancetype)predicateWithUsernames:(NSArray<NSString *> *)usernames
{
    return [SKYUserDiscoverPredicate predicateWithEmails:nil usernames:usernames];
}

@end
