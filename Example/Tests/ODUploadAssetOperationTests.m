//
//  ODUploadAssetOperationTests.m
//  ODKit
//
//  Created by Kenji Pa on 7/7/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

@interface ODUploadAssetOperation ()

- (NSURLRequest *)makeRequest;
- (void)handleCompletionWithData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error;

@property (nonatomic, readwrite) NSURLSession *session;
@property (nonatomic, readwrite) NSURLSessionUploadTask *task;

@end

NSString * const BASE64_ENCODED_CONTENT = @"SSBhbSBhIGJveS4=";

SpecBegin(ODUploadAssetOperation)

describe(@"upload asset", ^{
    __block ODContainer *container = nil;
    __block ODAsset *asset = nil;

    beforeEach(^{
        container = [[ODContainer alloc] init];
        [container configAddress:@"ourd.test"];
        [container configureWithAPIKey:@"API_KEY"];
        [container updateWithUserRecordID:[ODUserRecordID recordIDWithUsername:@"USER_ID"]
                              accessToken:[[ODAccessToken alloc] initWithTokenString:@"ACCESS_TOKEN"]];

        asset = [ODAsset assetWithName:@"boy.txt" data:[[NSData alloc] initWithBase64EncodedString:BASE64_ENCODED_CONTENT options:0]];
    });

    it(@"makes request", ^{
        ODUploadAssetOperation *operation = [ODUploadAssetOperation operationWithAsset:asset];
        operation.container = container;

        NSURLRequest *request = [operation makeRequest];

        expect(request.HTTPMethod).to.equal(@"PUT");
        expect(request.URL).to.equal([NSURL URLWithString:@"http://ourd.test/files/boy.txt"]);
        expect(request.allHTTPHeaderFields).to.equal(@{
                                                       @"X-Ourd-API-Key": @"API_KEY",
                                                       @"X-Ourd-Access-Token": @"ACCESS_TOKEN",
                                                       });
    });

    it(@"parses response correctly", ^{
        ODUploadAssetOperation *operation = [ODUploadAssetOperation operationWithAsset:asset];
        operation.container = container;

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *data = @{@"result": @{
                                           @"$name": @"prefixed-body.txt",
                                           }
                                            };
            return [OHHTTPStubsResponse responseWithJSONObject:data statusCode:200 headers:nil];
        }];

        waitUntil(^(DoneCallback done) {
            operation.uploadAssetCompletionBlock = ^(ODAsset *returningAsset, NSError *operationError) {
                expect(returningAsset).to.beIdenticalTo(asset);
                expect(returningAsset.name).to.equal(@"prefixed-body.txt");
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
