//
//  ODRecordStorageCoordinator.m
//  ODKit
//
//  Created by atwork on 8/5/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <ODKit/ODKit.h>
#import "ODRecordStorageMemoryStore.h"
#import "ODRecordSynchronizer.h"

SpecBegin(ODRecordStorageCoordinator)

describe(@"ODRecordStorageCoordinator", ^{
    __block ODContainer *container = nil;
    __block ODRecordStorageCoordinator *coordinator = nil;
    
    beforeEach(^{
        container = [ODContainer defaultContainer];
        coordinator = [[ODRecordStorageCoordinator alloc] initWithContainer:container];
    });
    
    it(@"init", ^{
        expect([coordinator class]).to.beSubclassOf([ODRecordStorageCoordinator class]);
    });
    
    it(@"manage record storage", ^{
        expect([coordinator recordStorages]).to.haveCountOf(0);
        ODRecordStorage *storage = [coordinator recordStorageForPrivateDatabase];
        expect([coordinator recordStorages]).to.haveCountOf(1);
        expect([coordinator recordStorages]).to.contain(storage);
        [coordinator forgetRecordStorage:storage];
        expect([coordinator recordStorages]).to.haveCountOf(0);
    });
    
    it(@"create private record storage", ^{
        ODRecordStorage *storage = [coordinator recordStorageForPrivateDatabase];
        expect([storage class]).to.beSubclassOf([ODRecordStorage class]);
    });
    
    it(@"create record storage", ^{
        ODRecordStorage *storage = [coordinator recordStorageWithDatabase:[container privateCloudDatabase]
                                                                  options:nil];
        expect([storage class]).to.beSubclassOf([ODRecordStorage class]);
        expect([storage backingStore]).to.conformTo(@protocol(ODRecordStorageBackingStore));
        expect([[storage synchronizer] class]).to.beSubclassOf([ODRecordSynchronizer class]);
    });
});

SpecEnd