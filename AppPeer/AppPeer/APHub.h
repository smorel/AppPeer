//
//  APHub.h
//  AppPeer
//
//  Created by Gabriel Lumbi on 12/22/2013.
//  Copyright (c) 2013 Wherecloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APPeer.h"

@interface APHub : NSObject

@property (nonatomic, readonly) NSArray* availablePeers;
@property (nonatomic, readonly) NSArray* connectedPeers;
@property (nonatomic, assign) BOOL autoConnect;

@property (nonatomic, copy) void (^didFindPeerBlock)(APPeer*);
@property (nonatomic, copy) void (^didConnectToPeerBlock)(APPeer*);
@property (nonatomic, copy) void (^didReceiveDataFromPeerBlock)(NSData*,APPeer*);
@property (nonatomic, copy) void (^didDisconnectFromPeerBlock)(APPeer*,NSError*);

-(id)initWithName:(NSString*)name;
-(id)initWithName:(NSString*)name subdomain:(NSString *)subdomain;

-(void)open;
-(void)close;

-(void)connectToPeer:(APPeer*)peer;
-(void)disconnectFromPeer:(APPeer*)peer;

-(void)send:(NSData*)data toPeer:(APPeer *)peer;
-(void)broadcast:(NSData*)data;

@end