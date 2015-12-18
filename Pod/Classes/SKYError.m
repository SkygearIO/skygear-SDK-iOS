//
//  SKYError.m
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

#import "SKYError.h"

NSString *const SKYErrorMessageKey = @"SKYErrorMessage";
NSString *const SKYErrorCodeKey = @"SKYErrorCode";
NSString *const SKYErrorTypeKey = @"SKYErrorType";
NSString *const SKYErrorInfoKey = @"SKYErrorInfo";
NSString *const SKYPartialErrorsByItemIDKey = @"SKYPartialErrorsByItemIDKey";
NSString *const SKYPartialEmailsNotFoundKey = @"SKYPartialEmailsNotFoundKey";

NSString *SKYErrorNameWithCode(SKYErrorCode errorCode)
{
    switch (errorCode) {
        case SKYErrorUnknownError:
            return @"UnknownError";
        case SKYErrorNetworkUnavailable:
            return @"NetworkUnavailable";
        case SKYErrorNetworkFailure:
            return @"NetworkFailure";
        case SKYErrorServiceUnavailable:
            return @"ServiceUnavailable";
        case SKYErrorBadResponse:
            return @"BadResponse";
        case SKYErrorInvalidData:
            return @"InvalidData";
        case SKYErrorNotAuthenticated:
            return @"NotAuthenticated";
        case SKYErrorPermissionDenied:
            return @"PermissionDenied";
        case SKYErrorAccessKeyNotAccepted:
            return @"AccessKeyNotAccepted";
        case SKYErrorAccessTokenNotAccepted:
            return @"AccessTokenNotAccepted";
        case SKYErrorInvalidCredentials:
            return @"InvalidCredentials";
        case SKYErrorInvalidSignature:
            return @"InvalidSignature";
        case SKYErrorBadRequest:
            return @"BadRequest";
        case SKYErrorInvalidArgument:
            return @"InvalidArgument";
        case SKYErrorDuplicated:
            return @"Duplicated";
        case SKYErrorResourceNotFound:
            return @"ResourceNotFound";
        case SKYErrorNotSupported:
            return @"NotSupported";
        case SKYErrorNotImplemented:
            return @"NotImplemented";
        case SKYErrorConstraintViolated:
            return @"ConstraintViolated";
        case SKYErrorIncompatibleSchema:
            return @"IncompatibleSchema";
        case SKYErrorAtomicOperationFailure:
            return @"AtomicOperationFailure";
        case SKYErrorPartialOperationFailure:
            return @"PartialOperationFailure";
        case SKYErrorUndefinedOperation:
            return @"UndefinedOperation";
        case SKYErrorUnexpectedError:
            return @"UnexpectedError";
        default:
            return @"UnexpectedError";
    }
}

NSString *SKYErrorLocalizedDescriptionWithCode(SKYErrorCode errorCode)
{
    switch (errorCode) {
        case SKYErrorUnknownError:
            return @"An unknown error has occurred.";
        case SKYErrorNetworkUnavailable:
            return @"Network is unavailable.";
        case SKYErrorNetworkFailure:
            return @"There was a network failure while processing the request.";
        case SKYErrorServiceUnavailable:
            return @"Service is unavailable at the moment.";
        case SKYErrorBadResponse:
            return @"The response sent by the server cannot be processed.";
        case SKYErrorInvalidData:
            return @"The data sent by the server cannot be processed.";
        case SKYErrorNotAuthenticated:
            return @"You have to be authenticated to perform this operation.";
        case SKYErrorPermissionDenied:
        case SKYErrorAccessKeyNotAccepted:
        case SKYErrorAccessTokenNotAccepted:
            return @"You are not allowed to perform this operation.";
        case SKYErrorInvalidCredentials:
            return @"You are not allowed to log in because the credentials you provided are not "
                   @"valid.";
        case SKYErrorInvalidSignature:
        case SKYErrorBadRequest:
            return @"The server is unable to process the request.";
        case SKYErrorInvalidArgument:
            return @"The server is unable to process the data.";
        case SKYErrorDuplicated:
            return @"This request contains duplicate of an existing resource on the server.";
        case SKYErrorResourceNotFound:
            return @"The requested resource is not found.";
        case SKYErrorNotSupported:
            return @"This operation is not supported.";
        case SKYErrorNotImplemented:
            return @"This operation is not implemented.";
        case SKYErrorConstraintViolated:
        case SKYErrorIncompatibleSchema:
        case SKYErrorAtomicOperationFailure:
        case SKYErrorPartialOperationFailure:
            return @"A problem occurred while processing this request.";
        case SKYErrorUndefinedOperation:
            return @"The requested operation is not available.";
        case SKYErrorUnexpectedError:
            return @"An unexpected error has occurred.";
        default:
            return @"An unexpected error has occurred.";
    }
}
