//
//  APDebug.h
//  AppPeer
//
//  Created by Gabriel Lumbi on 12/23/2013.
//  Copyright (c) 2013 Wherecloud Inc. All rights reserved.
//

#ifdef DEBUG
#define APDebugLog(s, ...) printf("<%s:(%d)> %s\n", [[[NSString stringWithUTF8String:__FILE__] lastPathComponent]UTF8String], __LINE__,[[NSString stringWithFormat:(s), ##__VA_ARGS__]UTF8String])
#else
#define APDebugLog(s, ...)
#endif