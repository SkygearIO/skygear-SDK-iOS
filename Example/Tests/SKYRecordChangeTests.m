//
//  SKYRecordStorageTests.m
//  SkyKit
//
//  Created by atwork on 7/5/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <SkyKit/SkyKit.h>
#import "SKYRecordChange_Private.h"

SpecBegin(SKYRecordChange)

describe(@"SKYRecordChange", ^{
    it(@"init", ^{
        SKYRecord *record = [[SKYRecord alloc] initWithRecordType:@"book"];
        SKYRecordChange *change;
        change = [[SKYRecordChange alloc] initWithRecord:record
                                                 action:SKYRecordChangeSave
                                          resolveMethod:SKYRecordResolveByUpdatingDelta
                                       attributesToSave:@{@"title": @[[NSNull null], @"Hello World"]}];
        
        expect([change class]).to.beSubclassOf([SKYRecordChange class]);
        expect(change.recordID).to.equal(record.recordID);
        expect(change.action).to.equal(SKYRecordChangeSave);
        expect(change.resolveMethod).to.equal(SKYRecordResolveByUpdatingDelta);
        expect(change.attributesToSave).to.equal(@{@"title": @[[NSNull null], @"Hello World"]});
    });

    it(@"set error", ^{
        SKYRecord *record = [[SKYRecord alloc] initWithRecordType:@"book"];
        SKYRecordChange *change;
        change = [[SKYRecordChange alloc] initWithRecord:record
                                                 action:SKYRecordChangeSave
                                          resolveMethod:SKYRecordResolveByUpdatingDelta
                                       attributesToSave:@{@"title": @[[NSNull null], @"Hello World"]}];
        change.finished = YES;
        change.error = [NSError errorWithDomain:@"UnknownErrorDomain" code:0 userInfo:nil];
        
        expect(change.finished).to.beTruthy();
        expect(change.error.domain).to.equal(@"UnknownErrorDomain");
    });
});

SpecEnd
