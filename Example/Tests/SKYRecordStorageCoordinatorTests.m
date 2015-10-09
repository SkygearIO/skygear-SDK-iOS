//
//  SKYRecordStorageCoordinator.m
//  SkyKit
//
//  Created by atwork on 8/5/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <SkyKit/SkyKit.h>
#import "SKYRecordStorageMemoryStore.h"
#import "SKYRecordSynchronizer.h"

SpecBegin(SKYRecordStorageCoordinator)

describe(@"SKYRecordStorageCoordinator", ^{
    __block SKYContainer *container = nil;
    __block SKYRecordStorageCoordinator *coordinator = nil;
    
    beforeEach(^{
        container = [SKYContainer defaultContainer];
        coordinator = [[SKYRecordStorageCoordinator alloc] initWithContainer:container];
        [coordinator forgetAllRecordStorages];
    });
    
    it(@"init", ^{
        expect([coordinator class]).to.beSubclassOf([SKYRecordStorageCoordinator class]);
    });
    
    it(@"manage record storage", ^{
        expect([coordinator registeredRecordStorages]).to.haveCountOf(0);
        SKYRecordStorage *storage = [coordinator recordStorageForPrivateDatabase];
        expect([coordinator registeredRecordStorages]).to.haveCountOf(1);
        expect([coordinator registeredRecordStorages]).to.contain(storage);
        [coordinator forgetRecordStorage:storage];
        expect([coordinator registeredRecordStorages]).to.haveCountOf(0);
    });
    
    it(@"create private record storage", ^{
        SKYRecordStorage *storage = [coordinator recordStorageForPrivateDatabase];
        expect([storage class]).to.beSubclassOf([SKYRecordStorage class]);
        expect([storage backingStore]).to.conformTo(@protocol(SKYRecordStorageBackingStore));
        expect([[storage synchronizer] class]).to.beSubclassOf([SKYRecordSynchronizer class]);
    });

    it(@"reusing existing record storage", ^{
        SKYRecordStorage *storage1 = [coordinator recordStorageForPrivateDatabase];
        SKYRecordStorage *storage2 = [coordinator recordStorageForPrivateDatabase];
        expect(storage1).to.equal(storage2);
    });

});

SpecEnd
