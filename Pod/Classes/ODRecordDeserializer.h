//
//  ODRecordDeserializer.h
//  askq
//
//  Created by Patrick Cheung on 9/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ODRecord.h"

@interface ODRecordDeserializer : NSObject

+ (instancetype)deserializer;

- (ODRecord *)recordWithDictionary:(NSDictionary *)dictionary;
- (ODRecord *)recordWithJSONData:(NSData *)data error:(NSError **)error;

@end
