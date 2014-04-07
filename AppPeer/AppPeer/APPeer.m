//
//  APPeer.m
//  AppPeer
//
//  Created by Gabriel Lumbi on 1/15/2014.
//  Copyright (c) 2014 Wherecloud Inc. All rights reserved.
//

#import "APPeer.h"

@implementation APPeer


+(id)peerFromNetService:(NSNetService *)netService{
    APPeer* peer = [APPeer new];
    peer.name = netService.name;
    peer.addresses = [netService.addresses mutableCopy];
    return peer;
}

-(id)init{
    if(self = [super init]){
        self.addresses = [NSMutableArray new];
    }
    return self;
}

-(BOOL)isEqual:(id)object{
    if(!object) return NO;
    if(![object isKindOfClass:[APPeer class]]) return NO;
    APPeer* otherPeer = (APPeer*)object;
    return [self.name isEqualToString:otherPeer.name];
}

@end
