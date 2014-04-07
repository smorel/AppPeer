//
//  AppDelegate.m
//  PeerMac
//
//  Created by Gabriel Lumbi on 11/3/2013.
//  Copyright (c) 2013 Wherecloud Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <AppPeerMac/AppPeer.h>

#define kSliderValue @"kSliderValue" //float
#define kDatePickerValue @"kDatePickerValue" //NSDate
#define kCheckbox1Value @"kCheckbox1Value" //BOOL
#define kCheckbox2Value @"kCheckbox2Value" //BOOL
#define kCheckbox3Value @"kCheckbox3Value" //BOOL

@implementation AppDelegate{
    APHub* _hub;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    
    self.UiState = [[NSMutableDictionary alloc] init];
    [self.UiState setValue:[NSNumber numberWithFloat:[self.slider floatValue]] forKey:kSliderValue];
    [self.UiState setValue:[self.datePicker dateValue] forKey:kDatePickerValue];
    [self.UiState setValue:[NSNumber numberWithBool:[self.checkbox1 state]==NSOnState] forKey:kCheckbox1Value];
    [self.UiState setValue:[NSNumber numberWithBool:[self.checkbox2 state]==NSOnState] forKey:kCheckbox2Value];
    [self.UiState setValue:[NSNumber numberWithBool:[self.checkbox3 state]==NSOnState] forKey:kCheckbox3Value];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    _hub = [[APHub alloc] initWithName:@"mac" subdomain:@"gab"];
    
    __block AppDelegate* bself = self;
    
    [_hub setDidReceiveDataFromPeerBlock:^(NSData *data, APPeer *peer) {
        bself.UiState = (NSMutableDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        [bself updateUI];
    }];
    
    [_hub setDidFindPeerBlock:^(APPeer *peer) {
    }];
    
    [_hub setDidConnectToPeerBlock:^(APPeer *peer) {
        [bself.tableView reloadData];
    }];
    
    [_hub setDidDisconnectFromPeerBlock:^(APPeer *peer, NSError *error) {
        [bself.tableView reloadData];
    }];
}

#pragma mark -
#pragma mark UI Actions

-(IBAction) connect:(id)sender{
    [_hub open];
}

-(IBAction) disconnect:(id)sender{
    [_hub close];
}

-(IBAction) sliderChanged:(id)sender{
    [self.UiState setValue:[NSNumber numberWithFloat:[self.slider floatValue]] forKey:kSliderValue];
    [self.sliderText setStringValue: [self.slider stringValue]];
    [self commitState];
}

-(IBAction) datePickerChanged:(id)sender{
    [self.UiState setValue:[self.datePicker dateValue] forKey:kDatePickerValue];
    [self commitState];
}

-(IBAction) checkbox1Changed:(id)sender{
    [self.UiState setValue:[NSNumber numberWithBool:[self.checkbox1 state]==NSOnState] forKey:kCheckbox1Value];
    [self commitState];
}

-(IBAction) checkbox2Changed:(id)sender{
    [self.UiState setValue:[NSNumber numberWithBool:[self.checkbox2 state]==NSOnState] forKey:kCheckbox2Value];
    [self commitState];
}

-(IBAction) checkbox3Changed:(id)sender{
    [self.UiState setValue:[NSNumber numberWithBool:[self.checkbox3 state]==NSOnState] forKey:kCheckbox3Value];
    [self commitState];
}

#pragma mark -
#pragma mark Table View Delegate

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSTextField *result = [tableView makeViewWithIdentifier:@"peers_table" owner:self];
    
    if (result == nil) {
        result = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 17)];
        result.identifier = @"peers_table";
    }
    
    result.stringValue = [[_hub.connectedPeers objectAtIndex:row] name];
    return result;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [_hub.connectedPeers count];
}

#pragma mark -
#pragma mark Utility

-(void)commitState{
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self.UiState];
    [_hub broadcast:data];
}

-(void)updateUI{
    [self.slider setFloatValue:[[self.UiState valueForKey:kSliderValue] floatValue]];
    [self.sliderText setStringValue: [self.slider stringValue]];
    [self.datePicker setDateValue:(NSDate*)[self.UiState valueForKey:kDatePickerValue]];
    [self.checkbox1 setState:[[self.UiState valueForKey:kCheckbox1Value] intValue]];
    [self.checkbox2 setState:[[self.UiState valueForKey:kCheckbox2Value] intValue]];
    [self.checkbox3 setState:[[self.UiState valueForKey:kCheckbox3Value] intValue]];
}

@end
