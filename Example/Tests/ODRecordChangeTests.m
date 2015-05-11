//
//  ODRecordStorageTests.m
//  ODKit
//
//  Created by atwork on 7/5/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <ODKit/ODKit.h>
#import "ODRecordChange_Private.h"

SpecBegin(ODRecordChange)

describe(@"ODRecordChange", ^{
    it(@"init", ^{
        ODRecord *record = [[ODRecord alloc] initWithRecordType:@"book"];
        ODRecordChange *change;
        change = [[ODRecordChange alloc] initWithRecord:record
                                                 action:ODRecordChangeSave
                                          resolveMethod:ODRecordResolveByUpdatingDelta
                                       attributesToSave:@{@"title": @[[NSNull null], @"Hello World"]}];
        
        expect([change class]).to.beSubclassOf([ODRecordChange class]);
        expect(change.recordID).to.equal(record.recordID);
        expect(change.action).to.equal(ODRecordChangeSave);
        expect(change.resolveMethod).to.equal(ODRecordResolveByUpdatingDelta);
        expect(change.attributesToSave).to.equal(@{@"title": @[[NSNull null], @"Hello World"]});
    });

    it(@"set error", ^{
        ODRecord *record = [[ODRecord alloc] initWithRecordType:@"book"];
        ODRecordChange *change;
        change = [[ODRecordChange alloc] initWithRecord:record
                                                 action:ODRecordChangeSave
                                          resolveMethod:ODRecordResolveByUpdatingDelta
                                       attributesToSave:@{@"title": @[[NSNull null], @"Hello World"]}];
        change.state = ODRecordChangeStateFinished;
        change.error = [NSError errorWithDomain:@"UnknownErrorDomain" code:0 userInfo:nil];
        
        expect(change.state).to.equal(ODRecordChangeStateFinished);
        expect(change.error.domain).to.equal(@"UnknownErrorDomain");
    });
});

SpecEnd