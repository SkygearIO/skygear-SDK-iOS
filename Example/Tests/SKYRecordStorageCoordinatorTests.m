//
//  SKYRecordStorageCoordinatorTests.m
//  SKYKit
//
//  Copyright 2015 Oursky Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "SKYRecordStorageMemoryStore.h"
#import "SKYRecordSynchronizer.h"
#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <SKYKit/SKYKit.h>

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

SpecBegin(SKYRecordStorageCoordinator)

    describe(@"SKYRecordStorageCoordinator", ^{
        __block SKYContainer *container = nil;
        __block SKYRecordStorageCoordinator *coordinator = nil;

        beforeEach(^{
            container = [SKYContainer testContainer];
            [container.auth updateWithUserRecordID:@"USERNAME"
                                       accessToken:[[SKYAccessToken alloc]
                                                       initWithTokenString:@"ACCESS_TOKEN"]];
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

#pragma GCC diagnostic pop
