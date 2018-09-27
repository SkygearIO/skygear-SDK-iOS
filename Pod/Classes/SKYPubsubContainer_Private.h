//
//  SKYPubsubContainer_Private.h
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

#import "SKYPubsubContainer.h"

#import "SKYContainer.h"
#import "SKYPubsubClient.h"

@interface SKYPubsubContainer ()

@property (nonatomic, weak) SKYContainer *container;

@property (nonatomic, strong) SKYPubsubClient *pubsubClient;

@property (nonatomic, strong) SKYPubsubClient *internalPubsubClient;

- (instancetype)initWithContainer:(SKYContainer *)container;

- (void)configInternalPubsubClient;

- (void)configAddress:(NSString *)address
    __attribute__((deprecated("Use -configAddress:apiKey: instead")));
- (void)configureWithAPIKey:(NSString *)APIKey
    __attribute__((deprecated("Use -configAddress:apiKey: instead")));
- (void)configAddress:(NSString *)address apiKey:(NSString *)apiKey;

@end
