//
//  APNetService.m
//  APPeerConnection
//
//  Created by Gabriel Lumbi on 11/3/2013.
//  Copyright (c) 2013 Wherecloud Inc. All rights reserved.
//

#import "APNetService.h"
#import "APDebug.h"

@implementation APNetService

+ (NSString*)typeWithSubdomain:(NSString*)subdomain{
    if(subdomain && [subdomain length] > 0){
        return [NSString stringWithFormat:kAPTypeFormat, subdomain];
    }else{
        return kAPDefaultType;
    }
}

-(id) initWithName:(NSString *)name subdomain:(NSString *)subdomain port:(UInt16)port{
    NSString* type = [APNetService typeWithSubdomain:subdomain];

    if(self = [super initWithDomain:kAPDomain type:type name:name port:port]){
        APDebugLog(@"Peer Link Service Initialized: %@", self.description);
    }
    return self;
}

@end