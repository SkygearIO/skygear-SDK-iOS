//
//  SKYRecord_Private.h
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

#import "SKYRecord.h"

@interface SKYRecord ()

@property (nonatomic, readwrite, copy) SKYRecordID *recordID;
@property (nonatomic, readwrite, copy) NSString *ownerUserRecordID;
@property (nonatomic, readwrite, copy) NSDate *creationDate;
@property (nonatomic, readwrite, copy) NSString *creatorUserRecordID;
@property (nonatomic, readwrite, copy) NSDate *modificationDate;
@property (nonatomic, readwrite, copy) NSString *lastModifiedUserRecordID;

@end
