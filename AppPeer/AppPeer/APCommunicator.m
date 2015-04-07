//
//  APCommunicator.m
//  APCommunicator
//
//  Created by Gabriel Lumbi on 11/2/2013.
//  Copyright (c) 2013 Wherecloud Inc. All rights reserved.
//

#import "APCommunicator.h"
#import "NSNetService+Additions.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "APDebug.h"

#define kUserDataPeerNameKey @"peer_name"
#define kDispatchQueueFormat @"com.apppeer.%@.%@"

@interface APCommunicator (Private)
- (void)connectToNextAddress:(GCDAsyncSocket*)socket;
@end

@implementation APCommunicator{
    
    dispatch_queue_t communicatorQueue;
    
    // Net service adverstized by this communicator
    APNetService* _netService;
    
    // Socket used to advertise net service and accept incoming connections
    GCDAsyncSocket *_acceptSocket;
    
    NSMutableDictionary* _outSockets; //"name" = socket
    NSMutableDictionary* _inSockets; //"name" = socket
    NSMutableDictionary* _peers; //"name" = peer
    
    NSInteger _port;
    
    // Sockets' userData property definition
    /*
     {
     "kUserDataPeerNameKey" = "name of the peer net service associated with the socket"
     }
     */
}

@synthesize name = _name;

-(id)initWithName:(NSString *)name{
    if(self = [self initWithName:name subdomain:nil]){
    }
    return self;
}

- (id) initWithName:(NSString*)name subdomain:(NSString *)subdomain{
    return [self initWithName:name subdomain:subdomain port:63273];
}

- (id) initWithName:(NSString*)name subdomain:(NSString *)subdomain port:(NSInteger)port{
    if(self = [super init]){
        
        communicatorQueue = dispatch_queue_create([[NSString stringWithFormat:kDispatchQueueFormat, subdomain, name, nil] UTF8String], NULL);
        
        self.dataSeparator = [GCDAsyncSocket CRLFData];
        
        _peers = [NSMutableDictionary new];
        _outSockets = [NSMutableDictionary new];
        _inSockets = [NSMutableDictionary new];
        
        self.name = name;
        self.subdomain = subdomain;
        self.port = port;
    }
    return self;
}

- (void)dealloc{
    
    for(GCDAsyncSocket* outSocket in _outSockets.allValues){
        [outSocket disconnect];
    }
    for(GCDAsyncSocket* inSocket in _inSockets.allValues){
        [inSocket disconnect];
    }
    
    [_acceptSocket disconnect];
    [_netService stop];
}

- (void) adverstize{
    _acceptSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *err = nil;
    if ([_acceptSocket acceptOnPort:self.port error:&err]){
        UInt16 port = self.port;//[_acceptSocket localPort];
        _netService = [[APNetService alloc] initWithName:self.name subdomain:self.subdomain port:port];
        [_netService publish];
        _netService.delegate = self;
    }else{
        APDebugLog(@"%@",err);
    }
}

-(NSArray*)peers{
    return [_peers allValues];
}

-(APPeer*) peerWithName:(NSString *)name{
    return [_peers valueForKey:name];
}

#pragma mark -
#pragma mark Connecting & Disconnecting

- (void) connectToPeer:(APPeer *)peer{
    GCDAsyncSocket* newOutSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    newOutSocket.userData = [NSDictionary dictionaryWithObject:peer.name forKey:kUserDataPeerNameKey];
    [_outSockets setValue:newOutSocket forKey:peer.name];
    [_peers setValue:peer forKey:peer.name];
    
    [self connectToNextAddress:newOutSocket];
}

- (void)connectToNetService:(NSNetService*) peerNetService{
    peerNetService.delegate = self;
    [peerNetService resolveWithTimeout:AP_SERVICE_RESOLVE_TIMEOUT];
}

- (void)disconnectFromAll{
    for(APPeer* peer in _peers){
        [self disconnectFromPeer:peer];
    }
}

- (void)disconnectFromPeer:(APPeer*)peer{
    GCDAsyncSocket* outSocket = [_outSockets valueForKey:peer.name];
    GCDAsyncSocket* inSocket = [_inSockets valueForKey:peer.name];
    
    if(outSocket){
        [outSocket disconnect];
    }
    if(inSocket) {
        [inSocket disconnect];
    }
    
    [_peers removeObjectForKey:peer.name];
}

- (void)clearSocketsForPeer:(APPeer*)peer{
    GCDAsyncSocket* outSocket = [_outSockets valueForKey:peer.name];
    GCDAsyncSocket* inSocket = [_inSockets valueForKey:peer.name];
    
    if(outSocket){
        outSocket.delegate = nil;
        [_outSockets removeObjectForKey:peer.name];
    }
    if(inSocket){
        inSocket.delegate = nil;
        [_inSockets removeObjectForKey:peer.name];
    }
}

#pragma mark -
#pragma mark Sending

-(void)sendAll:(NSData *)data{
    for(GCDAsyncSocket* outSocket in _outSockets.allValues){
        [outSocket writeData:data withTimeout:-1 tag:AP_DATA_TAG];
        [outSocket writeData:self.dataSeparator withTimeout:-1 tag:AP_DATA_SEPARATOR_TAG];
    }
}

-(void)send:(NSData *)data toPeer:(APPeer*)peer{
    GCDAsyncSocket* outSocket = [_outSockets objectForKey:peer.name];
    if(outSocket){
        [outSocket writeData:data withTimeout:-1 tag:AP_DATA_TAG];
        [outSocket writeData:self.dataSeparator withTimeout:-1 tag:AP_DATA_SEPARATOR_TAG];
    }
}

#pragma mark -
#pragma mark Net Service Delegation

- (void)netServiceDidResolveAddress:(NSNetService *)sender{
    [self connectToPeer:[APPeer peerFromNetService:sender]];
    [sender stop];
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict{
    APDebugLog(@"Net Service Did Not Publish : %@", errorDict);
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict{
    APDebugLog(@"Net Service Could Not Resolve : %@", errorDict);
}

#pragma mark -
#pragma mark GCD Async Socket Delegation

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    // Queue a read for the connection handshake
    [newSocket readDataToData:self.dataSeparator withTimeout:-1 tag:AP_HANDSHAKE_SERVICE_NAME_TAG];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    //Sending handshake infos
    [sock writeData:[_netService.name dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:AP_HANDSHAKE_SERVICE_NAME_TAG];
    [sock writeData:self.dataSeparator withTimeout:-1 tag:AP_DATA_SEPARATOR_TAG];
    
    [_outSockets setValue:sock forKey:[self peerForSocket:sock].name];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(peerCommunicator:didConnectToPeer:)]){
        [self.delegate peerCommunicator:self didConnectToPeer:[self peerForSocket:sock]];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    APPeer* peer = [self peerForSocket:sock];
    if(peer){
        NSString* peerName = peer.name;
        [self clearSocketsForPeer:peer];
        
        if(err){
            APDebugLog(@"Socket disconnected with error: %@",err);
        }
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(peerCommunicator:didDisconnectFromPeer:withError:)]){
            [self.delegate peerCommunicator:self didDisconnectFromPeer:peer withError:err];
        }
        
        if(peerName){
            [_peers removeObjectForKey:peerName];
        }
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSData* actuallyRead = [data subdataWithRange: NSMakeRange(0, data.length - self.dataSeparator.length)];
    
    if(tag == AP_HANDSHAKE_SERVICE_NAME_TAG){
        NSString* peerName = [[NSString alloc] initWithData:actuallyRead encoding:NSUTF8StringEncoding];
        sock.userData = [NSDictionary dictionaryWithObject:peerName forKey:kUserDataPeerNameKey];
        [_inSockets setValue:sock forKey:peerName];
        if(self.delegate && [self.delegate respondsToSelector:@selector(peerCommunicator:didAcceptPeer:)]){
            [self.delegate peerCommunicator:self didAcceptPeer:[_peers valueForKey:peerName]];
        }
        
        // Queue a data read
        [sock readDataToData:self.dataSeparator withTimeout:-1 tag:AP_DATA_TAG];
        
    }else if(tag == AP_DATA_TAG){
        if(self.delegate && [self.delegate respondsToSelector:@selector(peerCommunicator:didReceiveData:fromPeer:)]){
            [self.delegate peerCommunicator:self didReceiveData:actuallyRead fromPeer:[self peerForSocket:sock]];
        }
        
        // Queue a data read
        [sock readDataToData:self.dataSeparator withTimeout:-1 tag:AP_DATA_TAG];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    // Can be used to update progress bar or something
}

#pragma mark -
#pragma mark Private

- (void)connectToNextAddress:(GCDAsyncSocket*)socket{
    BOOL done = NO;
	
    APPeer* peer = [self peerForSocket:socket];
    
	while (!done && ([peer.addresses count] > 0))
	{
        NSData* addr = [peer.addresses objectAtIndex:0];
        [peer.addresses removeObjectAtIndex:0];
		
		NSError *err = nil;
		if ([socket connectToAddress:addr error:&err]){
			done = YES;
		}else{
			APDebugLog(@"Unable to connect: %@", err);
		}
	}
	
	if (!done){
        [self disconnectFromPeer:[self peerForSocket:socket]];
		APDebugLog(@"Unable to connect to any resolved address.");
	}
}

- (APPeer*)peerForSocket:(GCDAsyncSocket*)socket{
    if(socket.userData){
        NSString* peerName = [(NSDictionary*)socket.userData valueForKey:kUserDataPeerNameKey];
        return [_peers valueForKey:peerName];
    }
    
    return nil;
}

@end