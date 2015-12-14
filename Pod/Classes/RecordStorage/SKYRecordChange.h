//
//  SKYRecordChange.h
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

@class SKYRecord;
@class SKYRecordID;

typedef enum : NSInteger {
    /**
     SKYRecordStorage does not automatically resolve conflict,
     you have to check for failed changes and handle the error manually.
     */
    SKYRecordResolveManually,

    /**
     SKYRecordStorage will replace the remote record by saving with
     the local copy of the record, ignoring all existing attributes
     on remote.
     */
    SKYRecordResolveByReplacing,

    /**
     SKYRecordStorage will update the remote record by updating
     the remote copy with only the modified attributes.
     */
    SKYRecordResolveByUpdatingDelta,

    /**
     SKYRecordStorage will update the remote record if the modified
     attributes were not also modified on the remote.
     */
    SKYRecordResolveByUpdatingDeltaIfNotModified,
} SKYRecordResolveMethod;

typedef enum : NSInteger {
    SKYRecordChangeSave,
    SKYRecordChangeDelete,
} SKYRecordChangeAction;

@interface SKYRecordChange : NSObject <NSCoding>

@property (nonatomic, readonly, copy) SKYRecordID *recordID;
@property (nonatomic, readonly, copy) NSDictionary *attributesToSave;
@property (nonatomic, readonly) SKYRecordChangeAction action;
@property (nonatomic, readonly, getter=isFinished) BOOL finished;
@property (nonatomic, readonly) SKYRecordResolveMethod resolveMethod;
@property (nonatomic, readonly, copy) NSError *error;

- (instancetype)initWithRecord:(SKYRecord *)record
                        action:(SKYRecordChangeAction)action
                 resolveMethod:(SKYRecordResolveMethod)resolveMethod
              attributesToSave:(NSDictionary *)attributesToSave;

- (instancetype)initWithRecordID:(SKYRecordID *)recordID
                          action:(SKYRecordChangeAction)action
                   resolveMethod:(SKYRecordResolveMethod)resolveMethod
                attributesToSave:(NSDictionary *)attributesToSave;

@end
