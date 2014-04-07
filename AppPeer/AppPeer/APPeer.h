//
//  APPeer.h
//  AppPeer
//
//  Created by Gabriel Lumbi on 1/15/2014.
//  Copyright (c) 2014 Wherecloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APPeer : NSObject

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSMutableArray* addresses;


+(id)peerFromNetService:(NSNetService*)netService;

@end
