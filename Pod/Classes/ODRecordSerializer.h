//
//  ODRecordSerializer.h
//  askq
//
//  Created by Patrick Cheung on 9/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ODRecord.h"

@interface ODRecordSerializer : NSObject

/**
 Sets or return whether the serializer will serialize transient dictionary.

 Default is NO.
 */
@property (nonatomic, readwrite) BOOL serializeTransientDictionary;

+ (instancetype)serializer;

- (NSDictionary *)dictionaryWithRecord:(ODRecord *)record;
- (NSData *)JSONDataWithRecord:(ODRecord *)record error:(NSError **)error;

@end
