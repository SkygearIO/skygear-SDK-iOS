//
//  ODRecordIDTests.m
//  ODKit
//
//  Created by Patrick Cheung on 8/3/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <ODKit/ODKit.h>

SpecBegin(ODRecordID)

describe(@"ODRecordID", ^{
    it(@"init", ^{
        ODRecordID *recordID = [[ODRecordID alloc] initWithRecordType:@"book"];
        expect(recordID.recordType).to.equal(@"book");
        expect(recordID.recordName).toNot.beNil();
        expect([recordID.recordName class]).to.beSubclassOf([NSString class]);
        expect([recordID zoneID]).to.beNil();
        expect([recordID.description class]).to.beSubclassOf([NSString class]);
    });
    
    it(@"canonical string", ^{
        ODRecordID *recordID = [[ODRecordID alloc] initWithRecordType:@"book" name:@"book1"];
        expect(recordID.recordType).to.equal(@"book");
        expect(recordID.recordName).to.equal(@"book1");
        expect(recordID.canonicalString).to.equal(@"book/book1");
    });
});

SpecEnd