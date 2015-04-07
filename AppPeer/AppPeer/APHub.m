//
//  APHub.m
//  AppPeer
//
//  Created by Gabriel Lumbi on 12/22/2013.
//  Copyright (c) 2013 Wherecloud Inc. All rights reserved.
//

#import "APHub.h"
#import "APCommunicator.h"
#import "APPeerSource.h"
#import "APDebug.h"

@interface APHub () <APPeerSourceDelegate, APCommunicatorDelegate>
@property (nonatomic, retain) APCommunicator* peerCommunicator;
@property (nonatomic, retain) APPeerSource* peerSource;
@end

@implementation APHub{
    NSMutableArray* _connectedPeers;
}

#pragma mark -
#pragma mark Life Cycle

-(id)initWithName:(NSString *)name{
    return [self initWithName:name subdomain:nil];
}

-(id)initWithName:(NSString *)name subdomain:(NSString *)subdomain{
    return [self initWithName:name subdomain:subdomain port:63273];
}

-(id)initWithName:(NSString*)name subdomain:(NSString *)subdomain port:(NSInteger)port{
    if(self = [super init]){
        self.peerCommunicator = [[APCommunicator alloc] initWithName:name subdomain:subdomain port:port];
        self.peerCommunicator.delegate = self;
        
        self.peerSource = [[APPeerSource alloc] init];
        self.peerSource.delegate = self;
        
        __block APHub* bself = self;
        self.peerSource.filterBlock = ^BOOL(APPeer* peer){
            return ([bself.peerCommunicator.name isEqualToString:peer.name]);
        };
        self.autoConnect = YES;
        APDebugLog(@"Hub initialized for subdomain: %@", self.peerCommunicator.subdomain);
    }
    return self;
}

#pragma mark -
#pragma mark Properties

-(NSArray*)availablePeers{
    return _peerSource.peers;
}

-(NSArray*)connectedPeers{
    return _peerCommunicator.peers;
}

#pragma mark -
#pragma mark Instance Methods

-(void)open{
    APDebugLog(@"Hub opened. Accepting on subdomain: %@", self.peerCommunicator.subdomain);
    [self clean];
    [self.peerCommunicator adverstize];
    [_peerSource fetchInSubdomain:self.peerCommunicator.subdomain];
}

-(void)close{
    APDebugLog(@"Hub closed. Disconnecting all from subdomain: %@", self.peerCommunicator.subdomain);
    [self clean];
}

-(void)clean{
    _connectedPeers = [NSMutableArray new];
    if(self.peerSource){
        [_peerSource stop];
    }
    if(self.peerCommunicator){
        [self.peerCommunicator disconnectFromAll];
    }
}

-(void)connectToPeer:(APPeer *)peer{
    [self.peerCommunicator connectToPeer:peer];
}

-(void)disconnectFromPeer:(APPeer *)peer{
    [self.peerCommunicator disconnectFromPeer:peer];
}

-(void)send:(NSData *)data toPeer:(APPeer *)peer{
    [self.peerCommunicator send:data toPeer:peer];
}

-(void)broadcast:(NSData *)data{
    [self.peerCommunicator sendAll:data];
}

#pragma mark -
#pragma mark Peer Source Delegation

- (void) peerSource:(APPeerSource *)peerSource didFindPeer:(APPeer *)peer{

    if(self.didFindPeerBlock){
        self.didFindPeerBlock(peer);
    }
    if(self.autoConnect){
        [self.peerCommunicator connectToPeer:peer];
    }
}

- (void) peerSource:(APPeerSource *)peerSource didRemovePeer:(APPeer *)peer{
}

#pragma mark -
#pragma mark Communicator Delegation

-(void)peerCommunicator:(APCommunicator *)communicator didAcceptPeer:(APPeer *)peer{
}

-(void)peerCommunicator:(APCommunicator *)communicator didConnectToPeer:(APPeer *)peer{
    if(self.didConnectToPeerBlock){
        self.didConnectToPeerBlock(peer);
    }
}

-(void)peerCommunicator:(APCommunicator *)communicator didReceiveData:(NSData *)data fromPeer:(APPeer *)peer{
    if(self.didReceiveDataFromPeerBlock){
        self.didReceiveDataFromPeerBlock(data, peer);
    }
}

-(void)peerCommunicator:(APCommunicator *)communicator didDisconnectFromPeer:(APPeer *)peer withError:(NSError *)error{
    if(self.didDisconnectFromPeerBlock){
        self.didDisconnectFromPeerBlock(peer,error);
    }
}

@end
