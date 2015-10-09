//
//  NSURLRequestSKYRequestTests.m
//  SkyKit
//
//  Created by Patrick Cheung on 25/2/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SkyKit/SkyKit.h>

SpecBegin(NSURLRequestSKYRequest)

describe(@"request", ^{
    
    it(@"make url request", ^{
        NSString *action = @"auth:login";
        NSDictionary *payload = @{@"email": @"user@example.com"};
        
        SKYRequest *request = [[SKYRequest alloc] initWithAction:action payload:payload];
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithSKYRequest:request];
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
