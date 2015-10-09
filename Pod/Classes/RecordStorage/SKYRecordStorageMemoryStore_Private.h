//
//  SKYRecordStorageMemoryStore_Private.h
//  Pods
//
//  Created by atwork on 6/5/15.
//
//

#import <Foundation/Foundation.h>
#import "SKYRecordStorageMemoryStore.h"

@interface SKYRecordStorageMemoryStore ()

@property (nonatomic, readonly) NSMutableDictionary *records;
@property (nonatomic, readonly) NSMutableArray *changes;
@property (nonatomic, readonly) NSMutableDictionary *localRecords;

@end
