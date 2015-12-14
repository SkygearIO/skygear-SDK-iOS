//
//  SKYError.h
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

typedef enum : NSInteger {
    SKYErrorUnknownError = 1,
    SKYErrorPartialFailure = 2,
    SKYErrorNetworkFailure = 3,
} SKYErrorCode;

extern NSString *const SKYErrorMessageKey;
extern NSString *const SKYErrorCodeKey;
extern NSString *const SKYErrorTypeKey;
extern NSString *const SKYErrorInfoKey;
extern NSString *const SKYPartialErrorsByItemIDKey;
extern NSString *const SKYPartialEmailsNotFoundKey;
