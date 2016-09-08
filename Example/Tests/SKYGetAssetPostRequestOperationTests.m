//
//  SKYGetAssetPostRequestOperationTests.m
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

SpecBegin(SKYGetAssetPostRequestOperation)

    describe(@"get asset post request", ^{
        __block SKYContainer *container;
        __block SKYAsset *asset;

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
            SKYGetAssetPostRequestOperation *operation =
                [SKYGetAssetPostRequestOperation operationWithAsset:asset];
            [operation setContainer:container];
            [operation prepareForRequest];

            SKYRequest *request = operation.request;
            expect([request class]).to.beSubclassOf([SKYRequest class]);
            expect(request.action).to.equal(@"asset:put");
            expect(request.APIKey).to.equal(@"API-KEY");
            expect(request.accessToken.tokenString).to.equal(@"Test-Access-Token");
            expect(request.payload).to.equal(@{
                @"filename" : asset.name,
                @"content-type" : @"text/plain",
                @"content-size" : @11
            });
        });

        it(@"handle success response correctly", ^{
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *_Nonnull request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *_Nonnull(NSURLRequest *_Nonnull request) {
                    NSMutableDictionary *responseDict = [[NSMutableDictionary alloc] init];
                    responseDict[@"result"] = @{
                        @"asset" : @{
                            @"$name" : @"8a13d565-0075-42d8-a1a5-81d4c9d9901a-boy.txt",
                            @"$type" : @"asset",
                            @"$url" : @"http://skygear.dev/files/"
                                      @"8a13d565-0075-42d8-a1a5-81d4c9d9901a-boy.txt"
                        },
                        @"post-request" : @{
                            @"action" : @"http://asset.skygear.dev/dev/"
                                        @"8a13d565-0075-42d8-a1a5-81d4c9d9901a-boy.txt",
                            @"extra-fields" : @{
                                @"X-Extra-Field-1" : @"extra-value-1",
                                @"X-Extra-Field-2" : @"extra-value-2"
                            }
                        }
                    };

                    return [OHHTTPStubsResponse responseWithJSONObject:responseDict
                                                            statusCode:200
                                                               headers:nil];
                }];

            SKYGetAssetPostRequestOperation *operation =
                [SKYGetAssetPostRequestOperation operationWithAsset:asset];
            [operation setContainer:container];

            waitUntil(^(DoneCallback done) {
                operation.getAssetPostRequestCompletionBlock =
                    ^(SKYAsset *asset, NSURL *postURL,
                      NSDictionary<NSString *, NSObject *> *extraFields, NSError *operationError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect(asset).notTo.beNil();
                            expect(asset.name)
                                .to.equal(@"8a13d565-0075-42d8-a1a5-81d4c9d9901a-boy.txt");

                            expect(postURL).notTo.beNil();
                            expect(postURL.absoluteString)
                                .to.equal(@"http://asset.skygear.dev/dev/"
                                          @"8a13d565-0075-42d8-a1a5-"
                                          @"81d4c9d9901a-boy.txt");

                            expect(extraFields).notTo.beNil();
                            expect(extraFields[@"X-Extra-Field-1"]).to.equal(@"extra-value-1");
                            expect(extraFields[@"X-Extra-Field-2"]).to.equal(@"extra-value-2");

                            done();
                        });
                    };

                [container addOperation:operation];
            });
        });

        it(@"handle error response correctly", ^{
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *_Nonnull request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *_Nonnull(NSURLRequest *_Nonnull request) {
                    return [OHHTTPStubsResponse
                        responseWithError:[NSError errorWithDomain:NSURLErrorDomain
                                                              code:0
                                                          userInfo:nil]];
                }];

            SKYGetAssetPostRequestOperation *operation =
                [SKYGetAssetPostRequestOperation operationWithAsset:asset];
            [operation setContainer:container];

            waitUntil(^(DoneCallback done) {
                operation.getAssetPostRequestCompletionBlock =
                    ^(SKYAsset *asset, NSURL *postURL,
                      NSDictionary<NSString *, NSObject *> *extraFields, NSError *operationError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            expect(operationError).notTo.beNil();
                            done();
                        });
                    };

                [container addOperation:operation];
            });
        });
    });

SpecEnd