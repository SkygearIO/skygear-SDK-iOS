//
//  SKYAssetTests.m
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
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <SKYKit/SKYKit.h>

SpecBegin(SKYAsset)

    describe(@"SKYAsset", ^{
        it(@"copy creates a copy", ^{
            SKYAsset *asset =
                [SKYAsset assetWithData:[@"hello-world" dataUsingEncoding:NSUTF8StringEncoding]];
            SKYAsset *copiedAsset = [asset copy];

            expect(asset.name).to.equal(copiedAsset.name);
            expect(asset.url).to.equal(copiedAsset.url);
            expect(asset.mimeType).to.equal(copiedAsset.mimeType);
            expect(asset.fileSize).to.equal(copiedAsset.fileSize);
        });

        it(@"can be encoded and decoded", ^{
            SKYAsset *asset = [SKYAsset assetWithData:
                               [@"hello-world" dataUsingEncoding:NSUTF8StringEncoding]];

            NSData *archived = [NSKeyedArchiver archivedDataWithRootObject:asset];
            SKYAsset *unarchived = [NSKeyedUnarchiver unarchiveObjectWithData:archived];

            expect(asset.name).to.equal(unarchived.name);
            expect(asset.url).to.equal(unarchived.url);
            expect(asset.mimeType).to.equal(unarchived.mimeType);
            expect(asset.fileSize).to.equal(unarchived.fileSize);
        });
    });

SpecEnd
