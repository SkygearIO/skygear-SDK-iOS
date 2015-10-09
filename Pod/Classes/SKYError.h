//
//  SKYError.h
//  askq
//
//  Created by Kenji Pa on 21/1/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

typedef enum : NSInteger {
    SKYErrorUnknownError            = 1,
    SKYErrorPartialFailure          = 2,
    SKYErrorNetworkFailure          = 3,
} SKYErrorCode;

extern NSString * const SKYErrorMessageKey;
extern NSString * const SKYErrorCodeKey;
extern NSString * const SKYErrorTypeKey;
extern NSString * const SKYErrorInfoKey;
extern NSString * const SKYPartialErrorsByItemIDKey;
extern NSString * const SKYPartialEmailsNotFoundKey;
