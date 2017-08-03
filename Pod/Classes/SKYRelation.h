//
//  SKYRelation.h
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

/// Undocumented
typedef enum : NSInteger {
    SKYRelationDirectionOutward,
    SKYRelationDirectionInward,
    SKYRelationDirectionMutual
} SKYRelationDirection;

/// Undocumented
@interface SKYRelation : NSObject <NSCoding>

/// Undocumented
- (instancetype)init NS_UNAVAILABLE;

/// Undocumented
+ (instancetype)relationWithName:(NSString *)name direction:(SKYRelationDirection)direction;

/// Undocumented
+ (instancetype)friendRelation;
/// Undocumented
+ (instancetype)followingRelation;
/// Undocumented
+ (instancetype)followedRelation;

/// Undocumented
- (BOOL)isEqualToRelation:(SKYRelation *)relation;

/// Undocumented
@property (nonatomic, readonly, copy) NSString *name;
/// Undocumented
@property (nonatomic, readonly) SKYRelationDirection direction;

@end

NS_ASSUME_NONNULL_END
