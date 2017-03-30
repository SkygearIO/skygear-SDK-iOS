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
NSString *const SKYErrorNameKey = @"SKYErrorName";
NSString *const SKYPartialErrorsByItemIDKey = @"SKYPartialErrorsByItemIDKey";
NSString *const SKYPartialEmailsNotFoundKey = @"SKYPartialEmailsNotFoundKey";
NSString *const SKYOperationErrorDomain = @"SKYOperationErrorDomain";
NSString *const SKYOperationErrorHTTPStatusCodeKey = @"SKYOperationErrorHTTPStatusCodeKey";

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
        case SKYErrorRequestPayloadTooLarge:
            return @"RequestPayloadTooLarge";
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
            return NSLocalizedString(@"An unknown error has occurred.", nil);
        case SKYErrorNetworkUnavailable:
            return NSLocalizedString(@"Network is unavailable.", nil);
        case SKYErrorNetworkFailure:
            return NSLocalizedString(@"There was a network failure while processing the request.",
                                     nil);
        case SKYErrorServiceUnavailable:
            return NSLocalizedString(@"Service is unavailable at the moment.", nil);
        case SKYErrorBadResponse:
            return NSLocalizedString(@"The response sent by the server cannot be processed.", nil);
        case SKYErrorInvalidData:
            return NSLocalizedString(@"The data sent by the server cannot be processed.", nil);
        case SKYErrorRequestPayloadTooLarge:
            return NSLocalizedString(@"The data trying to be sent to the server is too large.",
                                     nil);
        case SKYErrorNotAuthenticated:
            return NSLocalizedString(@"You have to be authenticated to perform this operation.",
                                     nil);
        case SKYErrorPermissionDenied:
        case SKYErrorAccessKeyNotAccepted:
        case SKYErrorAccessTokenNotAccepted:
            return NSLocalizedString(@"You are not allowed to perform this operation.", nil);
        case SKYErrorInvalidCredentials:
            return NSLocalizedString(
                @"You are not allowed to log in because the credentials you provided are not "
                @"valid.",
                nil);
        case SKYErrorInvalidSignature:
        case SKYErrorBadRequest:
            return NSLocalizedString(@"The server is unable to process the request.", nil);
        case SKYErrorInvalidArgument:
            return NSLocalizedString(@"The server is unable to process the data.", nil);
        case SKYErrorDuplicated:
            return NSLocalizedString(
                @"This request contains duplicate of an existing resource on the server.", nil);
        case SKYErrorResourceNotFound:
            return NSLocalizedString(@"The requested resource is not found.", nil);
        case SKYErrorNotSupported:
            return NSLocalizedString(@"This operation is not supported.", nil);
        case SKYErrorNotImplemented:
            return NSLocalizedString(@"This operation is not implemented.", nil);
        case SKYErrorConstraintViolated:
        case SKYErrorIncompatibleSchema:
        case SKYErrorAtomicOperationFailure:
        case SKYErrorPartialOperationFailure:
            return NSLocalizedString(@"A problem occurred while processing this request.", nil);
        case SKYErrorUndefinedOperation:
            return NSLocalizedString(@"The requested operation is not available.", nil);
        case SKYErrorUnexpectedError:
            return NSLocalizedString(@"An unexpected error has occurred.", nil);
        default:
            return NSLocalizedString(@"An unexpected error has occurred.", nil);
    }
}
