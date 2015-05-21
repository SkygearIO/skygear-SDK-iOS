//
//  ODRecordStorageSqliteStore.h
//  Pods
//
//  Created by atwork on 16/5/15.
//
//

#import <Foundation/Foundation.h>
#import "ODRecordStorageBackingStore.h"

@interface ODRecordStorageSqliteStore : NSObject <ODRecordStorageBackingStore>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFile:(NSString *)path NS_DESIGNATED_INITIALIZER;

@end
