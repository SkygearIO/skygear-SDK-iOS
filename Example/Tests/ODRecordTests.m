//
//  ODRecordTests.m
//  ODKit
//
//  Created by Patrick Cheung on 8/3/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <ODKit/ODKit.h>

SpecBegin(ODRecord)

describe(@"ODRecord", ^{
    it(@"init no id", ^{
        ODRecord *record = [[ODRecord alloc] initWithRecordType:@"book"];
        expect(record.recordID).toNot.beNil();
        expect(record.recordType).to.equal(@"book");
    });
    
    it(@"set attribute to nil", ^{
        ODRecord *record = [[ODRecord alloc] initWithRecordType:@"book"
                                                           name:@"HelloWorld"
                                                           data:@{@"title": @"Hello World"}];
        record[@"title"] = nil;
        expect(record[@"title"]).to.beNil();
    });

    it(@"set attribute to NSNull", ^{
        ODRecord *record = [[ODRecord alloc] initWithRecordType:@"book"
                                                           name:@"HelloWorld"
                                                           data:@{@"title": @"Hello World"}];
        record[@"title"] = [NSNull null];
        expect(record[@"title"]).to.beNil();
    });
    
});

SpecEnd