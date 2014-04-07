//
//  AppDelegate.h
//  PeerMac
//
//  Created by Gabriel Lumbi on 11/3/2013.
//  Copyright (c) 2013 Wherecloud Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppPeerMac/AppPeer.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property (retain) NSMutableDictionary* UiState;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTableView *tableView;

@property (assign) IBOutlet NSSlider *slider;
@property (assign) IBOutlet NSTextField *sliderText;
@property (assign) IBOutlet NSDatePicker *datePicker;
@property (assign) IBOutlet NSButton* checkbox1;
@property (assign) IBOutlet NSButton* checkbox2;
@property (assign) IBOutlet NSButton* checkbox3;

-(IBAction) connect:(id)sender;
-(IBAction) disconnect:(id)sender;

-(IBAction) sliderChanged:(id)sender;
-(IBAction) datePickerChanged:(id)sender;
-(IBAction) checkbox1Changed:(id)sender;
-(IBAction) checkbox2Changed:(id)sender;
-(IBAction) checkbox3Changed:(id)sender;

@end