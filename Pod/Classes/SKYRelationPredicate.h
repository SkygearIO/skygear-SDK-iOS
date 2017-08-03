//
//  SKYRelationPredicate.h
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

NS_ASSUME_NONNULL_BEGIN

@class SKYRelation;

/**
 * The <SKYRelationPredicate> specifies a condition by whether a user
 * relation exists between two user, one being the user saved in a record
 * attribute an another being the current user.
 */
@interface SKYRelationPredicate : NSPredicate

/**
 * Returns the relation in the predicate.
 */
@property (nonatomic, readonly) SKYRelation *relation;

/**
 * Returns the key path of the attribute to be compared. The attribute should
 * store the user ID of a user.
 */
@property (nonatomic, readonly) NSString *keyPath;

/**
 * Returns an instance of <SKYRelationPredicate>.
 */
+ (instancetype)predicateWithRelation:(SKYRelation *)relation keyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
