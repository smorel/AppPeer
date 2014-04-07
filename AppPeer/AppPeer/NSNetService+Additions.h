//
//  NSNetService+Additions.h
//  AppPeer
//
//  Created by Gabriel Lumbi on 11/5/2013.
//  Copyright (c) 2013 Wherecloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#warning Unused

@interface NSNetService (Additions)

- (BOOL)retreiveInputStream:(out NSInputStream **)inputStreamPtr
               outputStream:(out NSOutputStream **)outputStreamPtr;

@end
