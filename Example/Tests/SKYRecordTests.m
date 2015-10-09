//
//  SKYRecordTests.m
//  SkyKit
//
//  Created by Patrick Cheung on 8/3/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <SkyKit/SkyKit.h>

SpecBegin(SKYRecord)

describe(@"SKYRecord", ^{
    it(@"init no id", ^{
        SKYRecord *record = [SKYRecord recordWithRecordType:@"book"];
        expect(record.recordID).toNot.beNil();
        expect(record.recordType).to.equal(@"book");
    });
    
    it(@"set attribute to nil", ^{
        SKYRecord *record = [SKYRecord recordWithRecordType:@"book"
                                                     name:@"HelloWorld"
                                                     data:@{@"title": @"Hello World"}];
        record[@"title"] = nil;
        expect(record[@"title"]).to.beNil();
    });

    it(@"set attribute to NSNull", ^{
        SKYRecord *record = [SKYRecord recordWithRecordType:@"book"
                                                     name:@"HelloWorld"
                                                     data:@{@"title": @"Hello World"}];
        record[@"title"] = [NSNull null];
        expect(record[@"title"]).to.beNil();
    });
    
});

SpecEnd
