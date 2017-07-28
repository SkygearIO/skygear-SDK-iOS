//
//  SKYPubsubClient.m
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

#import "SKYPubsubClient.h"

#import "NSURLRequest+SKYRequest.h"
#import "SRWebSocket.h"

double const SKYPubsubPingInterval = 10.0;
double const SKYPubsubReconnectWait = 1.0;

@interface SKYPubsubClient () <SRWebSocketDelegate>

@end

@implementation SKYPubsubClient {
    SRWebSocket *_webSocket;
    NSMutableDictionary *_channelHandlers;
    NSMutableArray *_pendingPublish;
    bool _opened;
    bool _connecting;
    bool _closing;
}

- (instancetype)initWithEndPoint:(NSURL *)endPoint APIKey:(NSString *)APIKey
{
    self = [super init];
    if (self) {
        _endPointAddress = [endPoint copy];
        _APIKey = [APIKey copy];
        _channelHandlers = [[NSMutableDictionary alloc] init];
        _pendingPublish = [[NSMutableArray alloc] init];
        _opened = false;
        _connecting = false;
        _closing = false;
        [NSTimer scheduledTimerWithTimeInterval:SKYPubsubPingInterval
                                         target:self
                                       selector:@selector(sendPing)
                                       userInfo:nil
                                        repeats:YES];
    }
    return self;
}

- (void)reconnectIfOpen
{
    if (_connecting) {
        _connecting = false;
        _webSocket.delegate = nil;
        [_webSocket close];
        [self connect];
        return;
    } else if (_opened && _endPointAddress != nil && _APIKey != nil) {
        [_webSocket close];
        [self connect];
    }
}

- (void)setEndPointAddress:(NSURL *)endPointAddress
{
    _endPointAddress = [endPointAddress copy];
    [self reconnectIfOpen];
}

- (void)setAPIKey:(NSString *)APIKey
{
    _APIKey = [APIKey copy];
    [self reconnectIfOpen];
}

- (SRWebSocket *)makeWebSocket
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:_endPointAddress];
    [request setValue:self.APIKey forHTTPHeaderField:SKYRequestHeaderAPIKey];
    return [[SRWebSocket alloc] initWithURLRequest:request];
}

- (void)connect
{
    if (!_opened && !_connecting) {
        _closing = false;
        _connecting = true;
        _webSocket = [self makeWebSocket];
        _webSocket.delegate = self;
        [_webSocket open];
    }
}

- (void)close
{
    if (_opened) {
        _closing = true;
        [_webSocket close];
    }
}

- (void)subscribeTo:(NSString *)channel handler:(void (^)(NSDictionary *))messageHandler
{
    [_channelHandlers setObject:[messageHandler copy] forKey:channel];
    if (!_opened) {
        [self connect];
    } else {
        [self send:@{@"action" : @"sub", @"channel" : channel}];
    }
}

- (void)unsubscribe:(NSString *)channel
{
    [_channelHandlers removeObjectForKey:channel];
    [self send:@{@"action" : @"unsub", @"channel" : channel}];
}

- (void)publishMessage:(NSDictionary *)message toChannel:(NSString *)channel
{
    [_pendingPublish addObject:@{@"action" : @"pub", @"channel" : channel, @"data" : message}];
    if (!_opened) {
        [self connect];
    } else {
        [self publishPending];
    }
}

- (void)publishPending
{
    for (NSDictionary *msg in _pendingPublish) {
        [self send:msg];
    }
    [_pendingPublish removeAllObjects];
}

- (void)send:(NSDictionary *)payload
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&error];
    if (!jsonData) {
        NSLog(@"Encoding error: %@", error.localizedDescription);
    } else {
        [_webSocket send:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    }
}

- (void)sendPing
{
    if (_opened) {
        NSLog(@"Ping Skygear websocket");
        [_webSocket sendPing:nil];
    }
}

#pragma mark - SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    _opened = true;
    _connecting = false;
    for (NSString *key in _channelHandlers) {
        [self send:@{@"action" : @"sub", @"channel" : key}];
    }
    [self publishPending];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"Websocket Failed With Error %@, will try to reconnect", error);
    _webSocket = nil;
    _opened = false;
    _connecting = false;
    [NSTimer scheduledTimerWithTimeInterval:SKYPubsubReconnectWait
                                     target:self
                                   selector:@selector(connect)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    if (![message isKindOfClass:[NSString class]]) {
        NSLog(@"%@ only support websocket message of class NSData. Got %@.",
              NSStringFromClass([self class]), message);
        return;
    }

    NSData *objectData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonData =
        [NSJSONSerialization JSONObjectWithData:objectData options:0 error:&error];
    if (jsonData && jsonData[@"channel"]) {
        void (^cb)(NSDictionary *message) = [_channelHandlers objectForKey:jsonData[@"channel"]];
        if (cb) {
            cb(jsonData[@"data"]);
        }
    } else {
        if (error) {
            NSLog(@"JSON Decoding error: %@", error.localizedDescription);
        } else {
            NSLog(@"Unhandled action: %@", message);
        }
    }
}

- (void)webSocket:(SRWebSocket *)webSocket
    didCloseWithCode:(NSInteger)code
              reason:(NSString *)reason
            wasClean:(BOOL)wasClean
{
    _webSocket = nil;
    _opened = false;
    if (!_closing) {
        NSLog(@"Websocket unexpected handup by remote, trying to reconnect");
        [self connect];
    } else {
        _closing = false;
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;
{
    // Nothing to do. Ping pong just to keep alive.
    return;
}

@end
