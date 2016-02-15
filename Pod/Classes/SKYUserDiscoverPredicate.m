//
//  SKYUserDiscoverPredicate.m
//  Pods
//
//  Created by atwork on 3/2/2016.
//
//

#import "SKYUserDiscoverPredicate.h"

@implementation SKYUserDiscoverPredicate

- (instancetype)init
{
    if (self == [super init]) {
    }
    return self;
}

+ (instancetype)predicateWithEmails:(NSArray *)emails
{
    SKYUserDiscoverPredicate *p = [[SKYUserDiscoverPredicate alloc] init];
    p->_emails = [emails copy];
    if (![p->_emails isKindOfClass:[NSArray class]]) {
        p->_emails = [NSArray array];
    }
    return p;
}

@end
