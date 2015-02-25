//
//  NSURLRequestODRequestTests.m
//  ODKit
//
//  Created by Patrick Cheung on 25/2/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>

SpecBegin(NSURLRequestODRequest)

describe(@"request", ^{
    
    it(@"make url request", ^{
        NSString *action = @"auth:login";
        NSDictionary *payload = @{@"email": @"user@example.com"};
        
        ODRequest *request = [[ODRequest alloc] initWithAction:action payload:payload];
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithODRequest:request];
        expect(urlRequest).notTo.beNil();
        expect([urlRequest.URL path]).to.endWith(@"auth/login");
        expect([urlRequest valueForHTTPHeaderField:@"Content-Type"]).to.equal(@"application/json");

        NSError *error = nil;
        NSDictionary *parameters = [NSJSONSerialization JSONObjectWithData:urlRequest.HTTPBody
                                                                   options:0 error:&error];
        
        expect(error).to.beNil();
        expect([parameters class]).to.beSubclassOf([NSDictionary class]);
        expect(parameters[@"email"]).to.equal(@"user@example.com");
    });
});

SpecEnd
