//
//  SKYRecordDeserializer.h
//  askq
//
//  Created by Patrick Cheung on 9/2/15.
//  Copyright (c) 2015 Rocky Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKYRecord.h"

@interface SKYRecordDeserializer : NSObject

+ (instancetype)deserializer;

- (SKYRecord *)recordWithDictionary:(NSDictionary *)dictionary;
- (SKYRecord *)recordWithJSONData:(NSData *)data error:(NSError **)error;

@end
