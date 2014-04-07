//
//  APNetService.h
//  APPeerConnection
//
//  Created by Gabriel Lumbi on 11/3/2013.
//  Copyright (c) 2013 Wherecloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAPDomain @"local."
#define kAPDefaultType @"_peerlink._tcp."
// [domain.][_peerlink_[subdomain]._tcp]
#define kAPTypeFormat @"_peerlink_%@._tcp."

@interface APNetService : NSNetService

+ (NSString*)typeWithSubdomain:(NSString*)subdomain;

- (id) initWithName:(NSString*)name subdomain:(NSString*)subdomain port:(UInt16)port;

@end