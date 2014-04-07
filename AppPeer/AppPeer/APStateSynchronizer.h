//
//  APPeerStateSynchronizer.h
//  AppPeer
//
//  Created by Gabriel Lumbi on 12/19/2013.
//  Copyright (c) 2013 Wherecloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCommunicator.h"

/*
 DEPRECATED
 */

@class APStateSynchronizer;

typedef void (^StateDidUpdateBlock)(APStateSynchronizer* synchronizer, NSData* newState);

@interface APStateSynchronizer : NSObject <APCommunicatorDelegate>

@property (nonatomic, weak) APCommunicator* peerCommunicator; //APStateSynchronizer takes APCommunicator's delegate ownership
@property (nonatomic, assign) NSData* state;
@property (nonatomic, copy) StateDidUpdateBlock stateDidUpdateBlock;
@property (nonatomic, weak) NSObject<APCommunicatorDelegate>* communicatorDelegate;

-(id)initWithCommunicator:(APCommunicator*) communicator;

@end