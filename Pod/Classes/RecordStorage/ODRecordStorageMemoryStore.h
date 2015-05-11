//
//  ODRecordStorageMemoryStore.h
//  Pods
//
//  Created by atwork on 5/5/15.
//
//

#import <Foundation/Foundation.h>
#import "ODRecordStorageBackingStore.h"

@class ODRecord;
@class ODRecordID;

@interface ODRecordStorageMemoryStore : NSObject <ODRecordStorageBackingStore>

@end
