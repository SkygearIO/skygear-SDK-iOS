//
//  SKYNotification.m
//  SKYKit
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
//

#import "SKYNotification_Private.h"

@implementation SKYNotification

- (instancetype)initWithSubscriptionID:(NSString *)subscriptionID
{
    self = [super init];
    if (self) {
        // notificationID not implemented, every notification is different.
        // TODO(limouren): implement notificationID when fetch notification is needed.
        self.notificationID = [[SKYNotificationID alloc] init];
        // we only have query notification at the moment
        self.notificationType = SKYNotificationTypeQuery;

        self.subscriptionID = [subscriptionID copy];
    }
    return self;
}

@end
