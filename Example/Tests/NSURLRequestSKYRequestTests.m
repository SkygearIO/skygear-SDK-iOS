//
//  NSURLRequestSKYRequestTests.m
//  SkyKit
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

#import <Foundation/Foundation.h>
#import <SkyKit/SkyKit.h>

SpecBegin(NSURLRequestSKYRequest)

    describe(@"request", ^{

        it(@"make url request", ^{
            NSString *action = @"auth:login";
            NSDictionary *payload = @{ @"email" : @"user@example.com" };

            SKYRequest *request = [[SKYRequest alloc] initWithAction:action payload:payload];

            NSURLRequest *urlRequest = [NSURLRequest requestWithSKYRequest:request];
            expect(urlRequest).notTo.beNil();
            expect([urlRequest.URL path]).to.endWith(@"auth/login");
            expect([urlRequest valueForHTTPHeaderField:@"Content-Type"])
                .to.equal(@"application/json");

            NSError *error = nil;
            NSDictionary *parameters =
                [NSJSONSerialization JSONObjectWithData:urlRequest.HTTPBody options:0 error:&error];

            expect(error).to.beNil();
            expect([parameters class]).to.beSubclassOf([NSDictionary class]);
            expect(parameters[@"email"]).to.equal(@"user@example.com");
        });
    });

SpecEnd
