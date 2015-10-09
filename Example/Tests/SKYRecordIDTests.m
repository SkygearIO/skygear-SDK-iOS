//
//  SKYRecordIDTests.m
//  SkyKit
//
//  Created by Patrick Cheung on 8/3/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <SkyKit/SkyKit.h>

SpecBegin(SKYRecordID)

describe(@"SKYRecordID", ^{
    it(@"init", ^{
        SKYRecordID *recordID = [SKYRecordID recordIDWithRecordType:@"book"];
        expect(recordID.recordType).to.equal(@"book");
        expect(recordID.recordName).toNot.beNil();
        expect([recordID.recordName class]).to.beSubclassOf([NSString class]);
        expect([recordID.description class]).to.beSubclassOf([NSString class]);
    });
    
    it(@"canonical string", ^{
        SKYRecordID *recordID = [SKYRecordID recordIDWithCanonicalString:@"book/book1"];
        expect(recordID.recordType).to.equal(@"book");
        expect(recordID.recordName).to.equal(@"book1");
        expect(recordID.canonicalString).to.equal(@"book/book1");
    });
});

SpecEnd
