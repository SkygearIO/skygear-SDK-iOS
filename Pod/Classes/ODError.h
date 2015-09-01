//
//  ODError.h
//  askq
//
//  Created by Kenji Pa on 21/1/15.
//  Copyright (c) 2015 RoODy Chan. All rights reserved.
//

typedef enum : NSInteger {
    ODErrorUnknownError            = 1,
    ODErrorPartialFailure          = 2,
    ODErrorNetworkFailure          = 3,
} ODErrorCode;

extern NSString * const ODErrorMessageKey;
extern NSString * const ODErrorCodeKey;
extern NSString * const ODErrorTypeKey;
extern NSString * const ODErrorInfoKey;
extern NSString * const ODPartialErrorsByItemIDKey;
extern NSString * const ODPartialEmailsNotFoundKey;
