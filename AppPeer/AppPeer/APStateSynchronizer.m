//
//  APPeerStateSynchronizer.m
//  AppPeer
//
//  Created by Gabriel Lumbi on 12/19/2013.
//  Copyright (c) 2013 Wherecloud Inc. All rights reserved.
//

#import "APStateSynchronizer.h"
#import "APCommunicator.h"

#ifdef AP_STATE_SYNCHRONIZER_DEPRECATED

@implementation APStateSynchronizer

#pragma mark -
#pragma mark Propreties

@synthesize state = _state;

-(void)setState:(NSData*) newState{
    _state = newState;
    [self.peerCommunicator sendAll:newState];
}

#pragma mark -
#pragma mark Life Cycle

-(id)initWithCommunicator:(APCommunicator*)communicator{
    if(self = [super init]){
        self.peerCommunicator = communicator;
        self.peerCommunicator.delegate = self;
    }
    return self;
}

#pragma mark -
#pragma mark Communicator Delegation

// Delegation is forwarded so that we can still listen the internal APCommunicator

-(void)peerCommunicator:(APCommunicator *)communicator didAcceptPeer:(NSString *)name{
    if(self.communicatorDelegate && [self.communicatorDelegate respondsToSelector:@selector(peerCommunicator:didAcceptPeer:)]){
        [self.communicatorDelegate peerCommunicator:communicator didAcceptPeer:name];
    }
}

-(void)peerCommunicator:(APCommunicator *)communicator didConnectToPeer:(NSString *)name{
    if(self.communicatorDelegate && [self.communicatorDelegate respondsToSelector:@selector(peerCommunicator:didConnectToPeer:)]){
        [self.communicatorDelegate peerCommunicator:communicator didConnectToPeer:name];
    }
}

-(void)peerCommunicator:(APCommunicator *)communicator didDisconnectFromPeer:(NSString *)name withError:(NSError *)error{
    if(self.communicatorDelegate && [self.communicatorDelegate respondsToSelector:@selector(peerCommunicator:didDisconnectFromPeer:withError:)]){
        [self.communicatorDelegate peerCommunicator:communicator didDisconnectFromPeer:name withError:error];
    }
}

-(void)peerCommunicator:(APCommunicator *)communicator didReceiveData:(NSData *)data fromPeer:(NSString *)name{
    if(communicator == self.peerCommunicator){
        _state = data;
        if(self.stateDidUpdateBlock){
            self.stateDidUpdateBlock(self, data);
        }
    }
    
    if(self.communicatorDelegate && [self.communicatorDelegate respondsToSelector:@selector(peerCommunicator:didReceiveData:fromPeer:)]){
        [self.communicatorDelegate peerCommunicator:communicator didReceiveData:data fromPeer:name];
    }
}

@end

#endif