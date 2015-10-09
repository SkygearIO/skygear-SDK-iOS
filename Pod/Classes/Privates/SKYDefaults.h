//
//  SKYDefaults.h
//  Pods
//
//  Created by Kenji Pa on 15/5/15.
//
//

#import <Foundation/Foundation.h>

@interface SKYDefaults : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)sharedDefaults;

@property (nonatomic, readwrite, copy) NSString *deviceID;

@end
