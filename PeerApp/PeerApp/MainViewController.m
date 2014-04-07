//
//  MainViewController.m
//  PeerApp
//
//  Created by Gabriel Lumbi on 11/5/2013.
//  Copyright (c) 2013 Wherecloud Inc. All rights reserved.
//

#import "MainViewController.h"

#define kSliderValue @"kSliderValue" //float
#define kDatePickerValue @"kDatePickerValue" //NSDate
#define kCheckbox1Value @"kCheckbox1Value" //BOOL
#define kCheckbox2Value @"kCheckbox2Value" //BOOL
#define kCheckbox3Value @"kCheckbox3Value" //BOOL

@interface MainViewController (){
    APHub* _hub;
    NSString* _incomingServiceName;
    NSNetService* _incomingNetService;
}

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        __block MainViewController* bself = self;
        
        _hub = [[APHub alloc] initWithName:[[UIDevice currentDevice] name] subdomain:@"gab"];
        
        _hub.autoConnect = NO;
        
        [_hub setDidFindPeerBlock:^(APPeer *peer) {
        }];
        
        [_hub setDidConnectToPeerBlock:^(APPeer *peer) {
            [bself updateConnectionStatus];
        }];
        
        [_hub setDidReceiveDataFromPeerBlock:^(NSData *data, APPeer *peer) {
            bself.UiState = (NSMutableDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
            [bself updateUI];
        }];
        
        [_hub setDidDisconnectFromPeerBlock:^(APPeer *peer, NSError *error) {
            [bself updateConnectionStatus];
            
            NSString* title = [NSString stringWithFormat:@"Disconnected from %@", peer.name];
            NSString* message = error ? [error localizedDescription] : nil;
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.UiState = [NSMutableDictionary new];
    
    [self.UiState setValue:[NSNumber numberWithFloat:self.slider.value] forKey:kSliderValue];
    [self.UiState setValue:self.datePicker.date forKey:kDatePickerValue];
    [self.UiState setValue:[NSNumber numberWithBool:self.checkbox1.isOn] forKey:kCheckbox1Value];
    [self.UiState setValue:[NSNumber numberWithBool:self.checkbox2.isOn] forKey:kCheckbox2Value];
    [self.UiState setValue:[NSNumber numberWithBool:self.checkbox3.isOn] forKey:kCheckbox3Value];
    
    [_hub open];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]
                                                initWithTitle:@"Peers"
                                                style:UIBarButtonItemStylePlain
                                                target:self
                                                action:@selector(showPeers)]];
}

-(void)viewDidAppear:(BOOL)animated{
    [self updateConnectionStatus];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark UI Actions

- (IBAction)sliderChanged:(id)sender{
    [self.UiState setValue:[NSNumber numberWithFloat:self.slider.value] forKey:kSliderValue];
    [self.sliderLabel setText:[NSString stringWithFormat:@"%f", self.slider.value]];
    [self commitState];
}

- (void)datePickerChanged:(id)sender{
    [self.UiState setValue:self.datePicker.date forKey:kDatePickerValue];
    [self commitState];
}

-(void)switch1Changed:(id)sender{
    [self.UiState setValue:[NSNumber numberWithBool:self.checkbox1.isOn] forKey:kCheckbox1Value];
    [self commitState];
}

-(void)switch2Changed:(id)sender{
    [self.UiState setValue:[NSNumber numberWithBool:self.checkbox2.isOn] forKey:kCheckbox2Value];
    [self commitState];
}
-(void)switch3Changed:(id)sender{
    [self.UiState setValue:[NSNumber numberWithBool:self.checkbox3.isOn] forKey:kCheckbox3Value];
    [self commitState];
}

-(void)commitState{
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self.UiState];
    [_hub broadcast:data];
}

-(void) showPeers{
    APPeerTableViewController* peerTableViewController = [[APPeerTableViewController alloc] initWithHub:_hub];
    [self.navigationController pushViewController:peerTableViewController animated:YES];
}

-(void)updateUI{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.slider setValue:[[self.UiState valueForKey:kSliderValue] floatValue] animated:NO];
        [self.sliderLabel setText:[NSString stringWithFormat:@"%f", self.slider.value]];
        [self.datePicker setDate:[self.UiState valueForKey:kDatePickerValue] animated:NO];
        [self.checkbox1 setOn:[[self.UiState valueForKey:kCheckbox1Value] boolValue] animated:NO];
        [self.checkbox2 setOn:[[self.UiState valueForKey:kCheckbox2Value] boolValue] animated:NO];
        [self.checkbox3 setOn:[[self.UiState valueForKey:kCheckbox3Value] boolValue] animated:NO];
    });
}

- (void)updateConnectionStatus{
    NSUInteger peersCount = [_hub.connectedPeers count];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(peersCount != 1){
            self.host.text = [NSString stringWithFormat:@"Connected to %lu peers", (unsigned long)peersCount];
        }else{
            self.host.text = @"Connected to one peer";
        }
    });
}

@end