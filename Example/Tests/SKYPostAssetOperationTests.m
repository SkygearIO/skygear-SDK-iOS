//
//  SKYPostAssetOperationTests.m
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

static NSString *const BASE64_ENCODED_CONTENT = @"SSBhbSBhIGJveS4=";

SpecBegin(SKYPostAssetOperation)

    describe(@"Upload Asset Operation", ^{
        __block SKYContainer *container = nil;
        __block SKYAsset *asset = nil;

        beforeEach(^{
            container = [[SKYContainer alloc] init];
            [container configAddress:@"http://skygear.dev/"];
            [container configureWithAPIKey:@"API-KEY"];
            [container updateWithUserRecordID:@"Test-User-ID"
                                  accessToken:[[SKYAccessToken alloc]
                                                  initWithTokenString:@"Test-Access-Token"]];

            asset = [SKYAsset
                assetWithName:@"boy.txt"
                         data:[[NSData alloc] initWithBase64EncodedString:BASE64_ENCODED_CONTENT
                                                                  options:0]];
            asset.mimeType = @"text/plain";
        });

        afterEach(^{
            [OHHTTPStubs removeAllStubs];
        });

        it(@"makes request correctly", ^{
            SKYPostAssetOperation *operation = [SKYPostAssetOperation
                operationWithAsset:asset
                               url:[NSURL URLWithString:@"http://asset.skygear.dev/dev/"
                                                        @"f8b9d47f-6188-46fa-b26f-0ac73fea2569-"
                                                        @"boy.txt"]
                       extraFields:@{
                           @"X-Extra-Field-1" : @"extra-value-1",
                           @"X-Extra-Field-2" : @123
                       }];
            operation.container = container;

            NSURLRequest *request = [operation makeURLRequest];

            expect(request.HTTPMethod).to.equal(@"POST");
            expect(request.URL.absoluteString)
                .to.equal(
                    @"http://asset.skygear.dev/dev/f8b9d47f-6188-46fa-b26f-0ac73fea2569-boy.txt");
            expect(request.allHTTPHeaderFields[@"X-Skygear-API-Key"]).to.equal(@"API-KEY");
            expect(request.allHTTPHeaderFields[@"X-Skygear-Access-Token"])
                .to.equal(@"Test-Access-Token");
            expect(request.allHTTPHeaderFields[@"Content-Type"]).notTo.beNil();
        });

    });

SpecEnd
