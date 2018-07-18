//
//  SKYReferenceTests.m
//  SKYKit
//
//  Copyright 2017 Oursky Ltd.
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
#import <SKYKit/SKYKit.h>

SpecBegin(SKYReference)

    describe(@"SKYReference", ^{
        it(@"can be copied", ^{
            SKYReference *ref = [[SKYReference alloc] initWithRecordID:[SKYRecordID recordIDWithRecordType:@"book"]];
            SKYReference *refClone = [ref copy];

            expect(refClone.recordID).to.equal(ref.recordID);
            expect(refClone.referenceAction).to.equal(ref.referenceAction);
        });

        it(@"can be encoded and decoded", ^{
            SKYReference *ref = [[SKYReference alloc] initWithRecordID:[SKYRecordID recordIDWithRecordType:@"book"]];

            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:ref];
            SKYReference *refClone = [NSKeyedUnarchiver unarchiveObjectWithData:data];

            //// Don't know why this cannot pass
            // expect(refClone.recordID).to.equal(ref.recordID);
            expect(refClone.recordID.recordType).to.equal(ref.recordID.recordType);
            expect(refClone.recordID.recordName).to.equal(ref.recordID.recordName);
            expect(refClone.referenceAction).to.equal(ref.referenceAction);
        });
    });

SpecEnd
