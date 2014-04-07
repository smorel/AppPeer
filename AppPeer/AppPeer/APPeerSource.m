//
//  APPeerBrowserView.m
//  AppPeer
//
//  Created by Gabriel Lumbi on 11/27/2013.
//  Copyright (c) 2013 Wherecloud Inc. All rights reserved.
//

#import "APPeerSource.h"
#import "APCommunicator.h"
#import "APDebug.h"

@interface APPeerSource ()
@property (nonatomic, retain) NSMutableArray* privatePeers;
@property (nonatomic, retain) NSNetServiceBrowser* peerBrowser;
@property (nonatomic, retain) NSMutableArray* currentlyResolvingNetServices;
@end

@implementation APPeerSource{
}

@synthesize peers, peerBrowser;

#pragma mark -
#pragma mark Life Cycle

-(id)init{
    self = [super init];
    if (self) {
        self.privatePeers = [NSMutableArray new];
        self.peerBrowser = [NSNetServiceBrowser new];
        self.peerBrowser.delegate = self;
        
        self.currentlyResolvingNetServices = [NSMutableArray new];
    }
    return self;
}

- (void)dealloc{
    [self.peerBrowser stop];
}

#pragma mark -
#pragma mark Properties

-(NSArray*)peers{
    return self.privatePeers;
}

#pragma mark -
#pragma mark Instance

-(void)fetch{
    [self.peerBrowser searchForServicesOfType:kAPDefaultType inDomain:kAPDomain];
}

-(void)fetchInSubdomain:(NSString *)subdomain{
    [self.peerBrowser searchForServicesOfType:[APNetService typeWithSubdomain:subdomain] inDomain:kAPDomain];
}

-(void)stop{
    [self.peerBrowser stop];
}

#pragma mark -
#pragma mark Net Service Delegation

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
          didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing{
    
    APPeer* peer = [APPeer peerFromNetService:aNetService];
    BOOL shouldFilter = self.filterBlock ? self.filterBlock(peer) : NO;
    if(!shouldFilter){
        APDebugLog(@"Peer found: %@ %@ -- Will start resolving address", aNetService.type, aNetService.name);
        aNetService.delegate = self;
        [aNetService resolveWithTimeout:AP_PEER_RESOLVE_TIMEOUT];
        [self.currentlyResolvingNetServices addObject:aNetService];
    }
}

-(void)netServiceDidResolveAddress:(NSNetService *)sender{
    APDebugLog(@"Peer address resolution completed: %@ %@", sender.type, sender.name);
    APPeer* peer = [APPeer peerFromNetService:sender];
    [self.privatePeers addObject:peer];
    if(self.delegate && [self.delegate respondsToSelector:@selector(peerSource:didFindPeer:)]){
        [self.delegate peerSource:self didFindPeer:peer];
    }
    [sender stop];
    [self.currentlyResolvingNetServices removeObject:sender];
}

-(void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict{
    APDebugLog(@"Could not resolve service: %@ %@", sender.type, sender.name);
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
        didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing{
    
    APPeer* peer = [APPeer peerFromNetService:aNetService];
    NSIndexSet* peersToRemove = [self.privatePeers indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if(obj && [obj isKindOfClass:[APPeer class]]){
            return [(APPeer*)obj isEqual:peer];
        }
        return NO;
    }];
    
    [self.privatePeers removeObjectsAtIndexes:peersToRemove];
    APDebugLog(@"Peer removed: %@", peer.name);
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(peerSource:didRemovePeer:)]){
        [self.delegate peerSource:self didRemovePeer:peer];
    }
    
    [self.currentlyResolvingNetServices removeObject:aNetService];
}


@end