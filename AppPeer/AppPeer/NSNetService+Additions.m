//
//  NSNetService+Additions.m
//  AppPeer
//
//  Created by Gabriel Lumbi on 11/5/2013.
//  Copyright (c) 2013 Wherecloud Inc. All rights reserved.
//

#import "NSNetService+Additions.h"

#warning Unused

@implementation NSNetService (Additions)

//This is a method proposed by Apple to overcome bugs created by getInputStream:outputStream:.
//https://developer.apple.com/library/ios/qa/qa1546/_index.html
- (BOOL)retreiveInputStream:(NSInputStream **)inputStreamPtr
               outputStream:(NSOutputStream **)outputStreamPtr
{
    BOOL                result;
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
    
    result = NO;
    
    readStream = NULL;
    writeStream = NULL;
    
    if ( (inputStreamPtr != NULL) || (outputStreamPtr != NULL) ) {
        CFNetServiceRef     netService;
        
        netService = CFNetServiceCreate(
                                        NULL,
                                        (__bridge CFStringRef) [self domain],
                                        (__bridge CFStringRef) [self type],
                                        (__bridge CFStringRef) [self name],
                                        0
                                        );
        if (netService != NULL) {
            CFStreamCreatePairWithSocketToNetService(
                                                     NULL,
                                                     netService,
                                                     ((inputStreamPtr  != NULL) ? &readStream : NULL),
                                                     ((outputStreamPtr != NULL) ? &writeStream : NULL)
                                                     );
            CFRelease(netService);
        }
        
        // We have failed if the client requested an input stream and didn't
        // get one, or requested an output stream and didn't get one. We also
        // fail if the client requested neither the input nor the output
        // stream, but we don't get here in that case.
        
        result = ! ((( inputStreamPtr != NULL) && ( readStream == NULL)) ||
                    ((outputStreamPtr != NULL) && (writeStream == NULL)));
    }
    if (inputStreamPtr != NULL) {
        *inputStreamPtr  = CFBridgingRelease(readStream);
    }
    if (outputStreamPtr != NULL) {
        *outputStreamPtr = CFBridgingRelease(writeStream);
    }
    
    return result;
}

@end
