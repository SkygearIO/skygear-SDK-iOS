//
//  SKYRecordSerializer.h
//  askq
//
//  Created by Patrick Cheung on 9/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKYRecord.h"

@interface SKYRecordSerializer : NSObject

/**
 Sets or return whether the serializer will serialize transient dictionary.

 Default is NO.
 */
@property (nonatomic, readwrite) BOOL serializeTransientDictionary;

+ (instancetype)serializer;

- (NSDictionary *)dictionaryWithRecord:(SKYRecord *)record;
- (NSData *)JSONDataWithRecord:(SKYRecord *)record error:(NSError **)error;

@end
