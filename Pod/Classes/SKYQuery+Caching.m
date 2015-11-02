
//
//  SKYQuery+Caching.m
//  Pods
//
//  Created by atwork on 13/4/15.
//
//

#import "SKYQuery+Caching.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation SKYQuery (Caching)

/**
 This generates the MD5 hash of NSData, which can be obtained by encoding `SKYQuery`.
 */
+ (NSString *)MD5CacheKeyStringWithData:(NSData *)data
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    return [NSString
        stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                         result[0], result[1], result[2], result[3], result[4], result[5],
                         result[6], result[7], result[8], result[9], result[10], result[11],
                         result[12], result[13], result[14], result[15]];
}

- (NSString *)cacheKey
{
    return [SKYQuery MD5CacheKeyStringWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
}

@end
