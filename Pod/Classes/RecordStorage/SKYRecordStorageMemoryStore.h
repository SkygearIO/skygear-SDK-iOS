//
//  SKYRecordStorageMemoryStore.h
//  Pods
//
//  Created by atwork on 5/5/15.
//
//

#import <Foundation/Foundation.h>
#import "SKYRecordStorageBackingStore.h"

@class SKYRecord;
@class SKYRecordID;

@interface SKYRecordStorageMemoryStore : NSObject <SKYRecordStorageBackingStore>

@end
