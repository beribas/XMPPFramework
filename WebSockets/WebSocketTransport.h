//
//  WebSocketTransport.h
//  XMPPFramework
//
//  Created by Oleg Langer on 16.03.17.
//  Copyright © 2017 robbiehanson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransportSocket.h"
@import CocoaAsyncSocket;


@interface WebSocketTransport : NSObject <TransportSocket>
@property (nonatomic, weak) id<GCDAsyncSocketDelegate> delegate;
@property dispatch_queue_t delegateQueue;

@end
