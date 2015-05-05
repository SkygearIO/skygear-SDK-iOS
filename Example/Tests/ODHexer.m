//
//  ODHexer.m
//  ODKit
//
//  Created by Kenji Pa on 4/5/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import "ODHexer.h"

@implementation ODHexer

// adopted from http://stackoverflow.com/a/7318062/1068664
+ (NSData *)dataWithHexString:(NSString *)hex
{
    NSMutableData *data = [NSMutableData dataWithCapacity:hex.length/2];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i = 0; i < hex.length/2; i++) {
        byte_chars[0] = [hex characterAtIndex:i*2];
        byte_chars[1] = [hex characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    return data;
}

@end
