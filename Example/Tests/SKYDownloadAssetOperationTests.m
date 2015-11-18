//
//  SKYDownloadAssetOperationTests.m
//  SkyKit
//
//  Created by Kenji Pa on 7/7/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SkyKit/SkyKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

#import "SKYAsset_Private.h"

@interface SKYUploadAssetOperation ()

- (NSURLRequest *)makeRequest;
- (void)handleCompletionWithData:(NSData *)data
                        response:(NSURLResponse *)response
                           error:(NSError *)error;

@property (nonatomic, readwrite) NSURLSession *session;
@property (nonatomic, readwrite) NSURLSessionUploadTask *task;

@end

static NSString *const BASE64_ENCODED_CONTENT = @"SSBhbSBhIGJveS4=";

SpecBegin(SKYDownloadAssetOperation)

    describe(@"upload asset", ^{
        __block SKYContainer *container = nil;
        __block SKYAsset *asset = nil;

        beforeEach(^{
            container = [[SKYContainer alloc] init];
            [container configAddress:@"ourd.test"];
            [container configureWithAPIKey:@"API_KEY"];
            [container updateWithUserRecordID:[SKYUserRecordID recordIDWithUsername:@"USER_ID"]
                                  accessToken:[[SKYAccessToken alloc]
                                                  initWithTokenString:@"ACCESS_TOKEN"]];

            asset = [SKYAsset
                assetWithName:@"prefixed-boy.txt"
                         data:[[NSData alloc] initWithBase64EncodedString:BASE64_ENCODED_CONTENT
                                                                  options:0]];
            asset.url = [NSURL URLWithString:@"http://ourd.test/files/prefixed-body.txt"];
        });

        it(@"makes request", ^{
            SKYUploadAssetOperation *operation = [SKYUploadAssetOperation operationWithAsset:asset];
            operation.container = container;

            NSURLRequest *request = [operation makeRequest];

            expect(request.HTTPMethod).to.equal(@"PUT");
            expect(request.URL)
                .to.equal([NSURL URLWithString:@"http://ourd.test/files/prefixed-boy.txt"]);
            expect(request.allHTTPHeaderFields)
                .to.equal(@{
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

        it(@"downloads remote file with completion", ^{
            SKYDownloadAssetOperation *operation =
                [SKYDownloadAssetOperation operationWithAsset:asset];
            operation.container = container;

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSData *data =
                        [[NSData alloc] initWithBase64EncodedString:BASE64_ENCODED_CONTENT
                                                            options:0];
                    return [OHHTTPStubsResponse responseWithData:data
                                                      statusCode:200
                                                         headers:@{
                                                             @"Content-Length" : @"11"
                                                         }];
                }];

            waitUntil(^(DoneCallback done) {
                operation.downloadAssetCompletionBlock =
                    ^(SKYAsset *returningAsset, NSData *data, NSError *operationError) {
                        expect(returningAsset).to.beIdenticalTo(asset);
                        expect(data).to.equal([[NSData alloc]
                            initWithBase64EncodedString:BASE64_ENCODED_CONTENT
                                                options:0]);
                        expect(operationError).to.beNil();
                        done();
                    };

                [operation start];
            });
        });

        it(@"downloads remote file with progress", ^{
            SKYDownloadAssetOperation *operation =
                [SKYDownloadAssetOperation operationWithAsset:asset];
            operation.container = container;

            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            }
                withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSData *data =
                        [[NSData alloc] initWithBase64EncodedString:BASE64_ENCODED_CONTENT
                                                            options:0];
                    return [OHHTTPStubsResponse responseWithData:data
                                                      statusCode:200
                                                         headers:@{
                                                             @"Content-Length" : @"11"
                                                         }];
                }];

            waitUntil(^(DoneCallback done) {
                operation.downloadAssetProgressBlock =
                    ^(SKYAsset *returningAsset, double progress) {
                        expect(returningAsset).to.beIdenticalTo(asset);
                        expect(progress).beGreaterThanOrEqualTo(0);
                        expect(progress).beLessThanOrEqualTo(1);
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
