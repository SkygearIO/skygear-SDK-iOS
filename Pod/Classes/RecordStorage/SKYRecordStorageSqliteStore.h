//
//  SKYRecordStorageSqliteStore.h
//  Pods
//
//  Created by atwork on 16/5/15.
//
//

#import <Foundation/Foundation.h>
#import "SKYRecordStorageBackingStore.h"

@interface SKYRecordStorageSqliteStore : NSObject <SKYRecordStorageBackingStore>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFile:(NSString *)path NS_DESIGNATED_INITIALIZER;

@end
