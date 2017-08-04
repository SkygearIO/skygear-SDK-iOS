//
//  SKYPublicDatabase.h
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

#import "SKYDatabase.h"

NS_ASSUME_NONNULL_BEGIN

/// Undocumented
@interface SKYPublicDatabase : SKYDatabase

/**
 *  Limit creation access of a record type to some roles
 *
 *  @param recordType      Record type to set creation access
 *  @param roles           Roles can create the record
 *  @param completionBlock Completion Block
 */
- (void)defineCreationAccessWithRecordType:(NSString *)recordType
                                     roles:(NSArray<SKYRole *> *)roles
                                completion:
                                    (void (^_Nullable)(NSError *_Nullable error))completionBlock;

/**
 *  Set default access of a record type
 *
 *  @param recordType      Record type to set creation access
 *  @param accessControl   Roles can create the record
 *  @param completionBlock Completion Block
 */
- (void)defineDefaultAccessWithRecordType:(NSString *)recordType
                                   access:(SKYAccessControl *)accessControl
                               completion:
                                   (void (^_Nullable)(NSError *_Nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END
