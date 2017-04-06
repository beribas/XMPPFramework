//
//  WebSocketsTransport.m
//  XMPPFramework
//
//  Created by Oleg Langer on 16.03.17.
//  Copyright © 2017 robbiehanson. All rights reserved.
//

#import "WebSocketsTransport.h"
#import "XMPPLogging.h"
@import SocketRocket;

NSString *const WebSocketErrorDomain = @"WebSocketErrorDomain";
typedef NS_ENUM(NSInteger, WebSocketError) {
    WebSocketErrorBadParam = 0
};


#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_INFO; // XMPP_LOG_LEVEL_VERBOSE | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

@interface WebSocketsTransport () <SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *webSocket;

@end

@implementation WebSocketsTransport

- (BOOL)connectToHost:(NSString *)host onPort:(uint16_t)port error:(NSError *__autoreleasing *)errPtr {
    if (host == nil || host.length == 0) {
        *errPtr = [NSError errorWithDomain:WebSocketErrorDomain code:WebSocketErrorBadParam userInfo:nil];
        return NO;
    }
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:host];
    if (!urlComponents.port) {
        urlComponents.port = @(port);
    }
    
    NSURL *url = urlComponents.URL;
    NSCParameterAssert(url);
    
    XMPPLogInfo(@"\n\nConnecting over web sockets to url:\n%@", url);
    
    self.webSocket = [[SRWebSocket alloc] initWithURL:url protocols:@[@"xmpp"] allowsUntrustedSSLCertificates:NO];
    self.webSocket.delegate = self;
    [self.webSocket open];
    return YES;
}

- (void)writeData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag {
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    XMPPLogInfo(@"\n\nWriting data to web socket:\n%@", string);
    [self.webSocket send:data];
}

- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag {
    
}

- (void)disconnect {
    [self.webSocket close];
}

#pragma mark SRWebSocketDelegate

// message will either be an NSString if the server is using text
// or NSData if the server is using binary.
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if ([message isKindOfClass:[NSString class]]) {
        NSLog(@"%s%@", __PRETTY_FUNCTION__, message);
    }
    else if ([message isKindOfClass:[NSData class]]){
        NSString *str = [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding];
        NSLog(@"%s%@", __PRETTY_FUNCTION__, str);
        
        dispatch_async(self.delegateQueue, ^{
            [self.delegate socket:nil didReadData:message withTag:0];
        });
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    dispatch_async(self.delegateQueue, ^{
        [self.delegate socket:nil didConnectToHost:nil port:0];
    });
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    dispatch_async(self.delegateQueue, ^{
        [self.delegate socketDidDisconnect:nil withError:error];
    });
    
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSError *error;
    if (!wasClean) {
        error = [NSError errorWithDomain:@"WebSocketErrorDomain" code:code userInfo:@{NSLocalizedDescriptionKey:reason}];
    }
    dispatch_async(self.delegateQueue, ^{
        [self.delegate socketDidDisconnect:nil withError:error];
    });
}
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    
}

// Return YES to convert messages sent as Text to an NSString. Return NO to skip NSData -> NSString conversion for Text messages. Defaults to YES.
- (BOOL)webSocketShouldConvertTextFrameToString:(SRWebSocket *)webSocket {
    return NO;
}

@end
