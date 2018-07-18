//
//  SKYRecordChangeTests.m
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

#import "SKYRecordChange_Private.h"
#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <SKYKit/SKYKit.h>

SpecBegin(SKYRecordChange)

    describe(@"SKYRecordChange", ^{
        it(@"init", ^{
            SKYRecord *record = [[SKYRecord alloc] initWithRecordType:@"book"];
            SKYRecordChange *change;
            change = [[SKYRecordChange alloc] initWithRecord:record
                                                      action:SKYRecordChangeSave
                                               resolveMethod:SKYRecordResolveByUpdatingDelta
                                            attributesToSave:@{
                                                @"title" : @[ [NSNull null], @"Hello World" ]
                                            }];

            expect([change class]).to.beSubclassOf([SKYRecordChange class]);
            expect(change.recordID).to.equal(record.recordID);
            expect(change.action).to.equal(SKYRecordChangeSave);
            expect(change.resolveMethod).to.equal(SKYRecordResolveByUpdatingDelta);
            expect(change.attributesToSave).to.equal(@{@"title" : @[ [NSNull null], @"Hello World" ]});
        });

        it(@"set error", ^{
            SKYRecord *record = [[SKYRecord alloc] initWithRecordType:@"book"];
            SKYRecordChange *change;
            change = [[SKYRecordChange alloc] initWithRecord:record
                                                      action:SKYRecordChangeSave
                                               resolveMethod:SKYRecordResolveByUpdatingDelta
                                            attributesToSave:@{
                                                @"title" : @[ [NSNull null], @"Hello World" ]
                                            }];
            change.finished = YES;
            change.error = [NSError errorWithDomain:@"UnknownErrorDomain" code:0 userInfo:nil];

            expect(change.finished).to.beTruthy();
            expect(change.error.domain).to.equal(@"UnknownErrorDomain");
        });
    });

SpecEnd
