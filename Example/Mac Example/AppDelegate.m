//
//  AppDelegate.m
//  Mac Example
//
//  Copyright 2018 Oursky Ltd.
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

#import "AppDelegate.h"
#import <SKYKit/SKYKit.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    // You can obtain the following information from portal.skygear.io
    [[SKYContainer defaultContainer] configAddress:@"https://example.skygeario.com"];
    [[SKYContainer defaultContainer] configureWithAPIKey:@"c4bf6faa7ccb4737b2342d2c319ff6f0"];
    
    // Login with username and password
    [[[SKYContainer defaultContainer] auth] loginWithUsername:@"johndoe"
                                                     password:@"passw0rd"
                                            completionHandler:^(SKYRecord *user, NSError *error) {
                                                if (error != nil) {
                                                    NSLog(@"An error occurred: %@", error);
                                                    return;
                                                }
                                                NSLog(@"User logged in: %@", user.recordID.recordName);
                                            }];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
