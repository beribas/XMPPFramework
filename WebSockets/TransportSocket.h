//
//  TransportSocket.h
//  XMPPFramework
//
//  Created by Oleg Langer on 16.03.17.
//  Copyright © 2017 robbiehanson. All rights reserved.
//

@import CocoaAsyncSocket;

@protocol TransportSocket <NSObject>

- (void)setDelegate:(id)newDelegate delegateQueue:(dispatch_queue_t)newDelegateQueue;
- (void)disconnect;
- (BOOL)connectToHost:(NSString*)host onPort:(uint16_t)port error:(NSError **)errPtr;
- (BOOL)connectToAddress:(NSData *)remoteAddr error:(NSError **)errPtr;
- (void)writeData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag;
- (void)disconnectAfterWriting;
- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag;
- (void)writeData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag;
- (void)startTLS:(NSDictionary *)tlsSettings;
- (void)performBlock:(dispatch_block_t)block;
- (BOOL)enableBackgroundingOnSocket;


@end

@interface GCDAsyncSocket (TransportSocket) <TransportSocket>

@end

