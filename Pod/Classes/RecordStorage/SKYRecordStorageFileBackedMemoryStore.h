//
//  SKYRecordStorageFileStore.h
//  Pods
//
//  Created by atwork on 6/5/15.
//
//

#import <Foundation/Foundation.h>
#import "SKYRecordStorageMemoryStore.h"

@interface SKYRecordStorageFileBackedMemoryStore : SKYRecordStorageMemoryStore

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFile:(NSString *)path NS_DESIGNATED_INITIALIZER;

@end
