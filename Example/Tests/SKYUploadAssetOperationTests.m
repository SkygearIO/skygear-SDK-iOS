//
//  SKYUploadAssetOperationTests.m
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

SpecBegin(SKYUploadAssetOperation)

    describe(@"upload asset", ^{
        __block SKYContainer *container = nil;
        __block SKYAsset *asset = nil;

        beforeEach(^{
            container = [[SKYContainer alloc] init];
            [container configAddress:@"http://ourd.test/"];
            [container configureWithAPIKey:@"API_KEY"];
            [container updateWithUserRecordID:@"USER_ID"
                                  accessToken:[[SKYAccessToken alloc]
                                                  initWithTokenString:@"ACCESS_TOKEN"]];

            asset = [SKYAsset
                assetWithName:@"boy.txt"
                         data:[[NSData alloc] initWithBase64EncodedString:BASE64_ENCODED_CONTENT
                                                                  options:0]];
            asset.mimeType = @"text/plain";
        });

        it(@"makes request", ^{
            SKYUploadAssetOperation *operation = [SKYUploadAssetOperation operationWithAsset:asset];
            operation.container = container;

            NSURLRequest *request = [operation makeURLRequest];

            expect(request.HTTPMethod).to.equal(@"PUT");
            expect(request.URL).to.equal([NSURL URLWithString:@"http://ourd.test/files/boy.txt"]);
            expect(request.allHTTPHeaderFields).to.equal(@{
                @"X-Skygear-API-Key" : @"API_KEY",
                @"X-Skygear-Access-Token" : @"ACCESS_TOKEN",
                @"Content-Type" : @"text/plain",
            });
        });

        it(@"makes request with escape character", ^{
            asset = [SKYAsset
                assetWithName:@"boy%boy.txt"
                         data:[[NSData alloc] initWithBase64EncodedString:BASE64_ENCODED_CONTENT
                                                                  options:0]];
            SKYUploadAssetOperation *operation = [SKYUploadAssetOperation operationWithAsset:asset];
            operation.container = container;

            NSURLRequest *request = [operation makeURLRequest];

            expect(request.HTTPMethod).to.equal(@"PUT");
            expect(request.URL)
                .to.equal([NSURL URLWithString:@"http://ourd.test/files/boy%25boy.txt"]);
            expect(request.allHTTPHeaderFields).to.equal(@{
                @"X-Skygear-API-Key" : @"API_KEY",
                @"X-Skygear-Access-Token" : @"ACCESS_TOKEN",
            });
        });

        it(@"parses response correctly", ^{
            SKYUploadAssetOperation *operation = [SKYUploadAssetOperation operationWithAsset:asset];
            operation.container = container;

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSDictionary *data = @{
                        @"result" : @{
                            @"$name" : @"prefixed-body.txt",
                        }
                    };
                    return [OHHTTPStubsResponse responseWithJSONObject:data
                                                            statusCode:200
                                                               headers:nil];
                }];

            waitUntil(^(DoneCallback done) {
                operation.uploadAssetCompletionBlock =
                    ^(SKYAsset *returningAsset, NSError *operationError) {
                        expect(returningAsset).to.beIdenticalTo(asset);
                        expect(returningAsset.name).to.equal(@"prefixed-body.txt");
                        done();
                    };

                [operation start];
            });
        });

        it(@"handles 413 entity too large error", ^{
            SKYUploadAssetOperation *operation = [SKYUploadAssetOperation operationWithAsset:asset];
            operation.container = container;

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSData *data = [@"Entity too large" dataUsingEncoding:NSUTF8StringEncoding];
                    return [OHHTTPStubsResponse responseWithData:data statusCode:413 headers:nil];
                }];

            waitUntil(^(DoneCallback done) {
                operation.uploadAssetCompletionBlock =
                    ^(SKYAsset *returningAsset, NSError *operationError) {
                        expect(returningAsset).to.beIdenticalTo(asset);
                        expect(operationError).notTo.beNil();
                        expect(operationError.code).to.equal(SKYErrorRequestPayloadTooLarge);
                        done();
                    };

                [operation start];
            });
        });

        afterEach(^{
            [OHHTTPStubs removeAllStubs];
        });
    });

SpecEnd
