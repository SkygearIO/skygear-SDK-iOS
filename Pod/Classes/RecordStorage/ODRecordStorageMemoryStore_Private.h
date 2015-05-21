//
//  ODRecordStorageMemoryStore_Private.h
//  Pods
//
//  Created by atwork on 6/5/15.
//
//

#import <Foundation/Foundation.h>
#import "ODRecordStorageMemoryStore.h"

@interface ODRecordStorageMemoryStore ()

@property (nonatomic, readonly) NSMutableDictionary *records;
@property (nonatomic, readonly) NSMutableArray *changes;
@property (nonatomic, readonly) NSMutableDictionary *localRecords;

@end
