//
//  APPeerBrowserView.h
//  AppPeer
//
//  Created by Gabriel Lumbi on 11/27/2013.
//  Copyright (c) 2013 Wherecloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APPeer.h"

#define AP_PEER_RESOLVE_TIMEOUT 5.0

@class APPeerSource;

@protocol APPeerSourceDelegate

- (void) peerSource:(APPeerSource*)peerSource didFindPeer:(APPeer*)peer;
- (void) peerSource:(APPeerSource*)peerSource didRemovePeer:(APPeer*)peer;

@end

typedef BOOL(^FilterBlock)(APPeer*); //Return YES if the net service should be filtered out

@interface APPeerSource : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@property (nonatomic, readonly) NSArray* peers;
@property (nonatomic, copy) FilterBlock filterBlock;
@property (nonatomic, weak) NSObject<APPeerSourceDelegate>* delegate;

-(void)fetch;
-(void)fetchInSubdomain:(NSString*) subdomain;
-(void)stop;

@end