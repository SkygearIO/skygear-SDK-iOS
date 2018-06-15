//
//  SKYDatabase_Private.h
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

@interface SKYDatabase ()

// TODO: look for a better way to override NS_UNAVAILABLE on init
- (instancetype)initWithContainer:(SKYContainer *)container databaseID:(NSString *)databaseID;

- (void)sky_presave:(id _Nullable)object
         completion:
             (void (^_Nullable)(id _Nullable presavedObject, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
