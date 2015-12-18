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

extern NSString *const SKYErrorMessageKey;
extern NSString *const SKYErrorCodeKey;
extern NSString *const SKYErrorTypeKey;
extern NSString *const SKYErrorNameKey;
extern NSString *const SKYErrorInfoKey;
extern NSString *const SKYPartialErrorsByItemIDKey;
extern NSString *const SKYPartialEmailsNotFoundKey;

typedef enum : NSInteger {
    SKYErrorUnknownError = 1,
    SKYErrorPartialFailure = 116,

    SKYErrorNetworkUnavailable = 4,
    SKYErrorNetworkFailure = 5,
    SKYErrorServiceUnavailable = 6,
    SKYErrorBadResponse = 8,
    SKYErrorInvalidData = 9,

    SKYErrorNotAuthenticated = 101,
    SKYErrorPermissionDenied = 102,
    SKYErrorAccessKeyNotAccepted = 103,
    SKYErrorAccessTokenNotAccepted = 104,
    SKYErrorInvalidCredentials = 105,
    SKYErrorInvalidSignature = 106,
    SKYErrorBadRequest = 107,
    SKYErrorInvalidArgument = 108,
    SKYErrorDuplicated = 109,
    SKYErrorResourceNotFound = 110,
    SKYErrorNotSupported = 111,
    SKYErrorNotImplemented = 112,
    SKYErrorConstraintViolated = 113,
    SKYErrorIncompatibleSchema = 114,
    SKYErrorAtomicOperationFailure = 115,
    SKYErrorPartialOperationFailure = 116,
    SKYErrorUndefinedOperation = 117,

    SKYErrorUnexpectedError = 10000,
} SKYErrorCode;

/**
 Returns a localized description for the error code.
 */
extern NSString *SKYErrorLocalizedDescriptionWithCode(SKYErrorCode errorCode);

/**
 Returns the name of the error code in string representation.
 */
extern NSString *SKYErrorNameWithCode(SKYErrorCode errorCode);
