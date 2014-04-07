//
//  APPeerTableViewController.h
//  AppPeer
//
//  Created by Gabriel Lumbi on 12/3/2013.
//  Copyright (c) 2013 Wherecloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APHub.h"

@interface APPeerTableViewController : UITableViewController

@property (nonatomic, weak) APHub* hub;

-(id)initWithHub:(APHub*)hub;

@end