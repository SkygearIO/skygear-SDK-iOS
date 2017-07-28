//
//  SKYRecordTests.m
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

#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <SKYKit/SKYKit.h>

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
                                                           data:@{@"title" : @"Hello World"}];
            record[@"title"] = nil;
            expect(record[@"title"]).to.beNil();
        });

        it(@"set attribute to NSNull", ^{
            SKYRecord *record = [SKYRecord recordWithRecordType:@"book"
                                                           name:@"HelloWorld"
                                                           data:@{@"title" : @"Hello World"}];
            record[@"title"] = [NSNull null];
            expect(record[@"title"]).to.beNil();
        });

    });

SpecEnd
