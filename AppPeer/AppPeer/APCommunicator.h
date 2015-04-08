//
//  APCommunicator.h
//  APCommunicator
//
//  Created by Gabriel Lumbi on 11/2/2013.
//  Copyright (c) 2013 Wherecloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APNetService.h"
#import "GCDAsyncSocket.h"
#import "APPeer.h"

#define AP_HANDSHAKE_SERVICE_NAME_TAG 1
#define AP_DATA_TAG 10
#define AP_DATA_SEPARATOR_TAG 9999
#define AP_SERVICE_RESOLVE_TIMEOUT 10

@class APCommunicator;

@protocol APCommunicatorDelegate

- (void)peerCommunicator:(APCommunicator *)communicator didReceiveData:(NSData *)data fromPeerNamed:(NSString*)peerName;

@optional
- (void) peerCommunicator: (APCommunicator*)communicator didAcceptPeer:(APPeer*)peer;
- (void) peerCommunicator:(APCommunicator*)communicator didConnectToPeer:(APPeer*)peer;
- (void) peerCommunicator:(APCommunicator*)communicator didDisconnectFromPeer:(APPeer*)peer withError:(NSError*)error;
@end

@interface APCommunicator : NSObject <NSNetServiceDelegate, GCDAsyncSocketDelegate>

@property (nonatomic, assign) NSObject<APCommunicatorDelegate>* delegate;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *subdomain;
@property (nonatomic, retain) NSData *dataSeparator;
@property (nonatomic, readonly) NSArray* peers;
@property (nonatomic, assign) NSInteger port;

- (id)initWithName:(NSString*) name;
- (id)initWithName:(NSString*) name subdomain:(NSString*) subdomain;
- (id)initWithName:(NSString*) name subdomain:(NSString*) subdomain port:(NSInteger)port;

- (void) adverstize;

- (void)connectToNetService:(NSNetService*) peerNetService;
- (void)connectToPeer:(APPeer*)peer;
- (void)disconnectFromAll;
- (void)disconnectFromPeer:(APPeer*)peer;

-(void)sendAll:(NSData*)data;
-(void)send:(NSData*)data toPeer:(APPeer*)peer;

-(APPeer*)peerWithName:(NSString*)name;

@end