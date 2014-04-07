//
//  MainViewController.h
//  PeerApp
//
//  Created by Gabriel Lumbi on 11/5/2013.
//  Copyright (c) 2013 Wherecloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AppPeerIOS/AppPeer.h>

@interface MainViewController : UIViewController

@property (nonatomic, strong) NSMutableDictionary* UiState;

@property (nonatomic, weak) IBOutlet UILabel* host;

@property (nonatomic, weak) IBOutlet UISlider* slider;
@property (nonatomic, weak) IBOutlet UILabel* sliderLabel;
@property (assign) IBOutlet UIDatePicker *datePicker;
@property (assign) IBOutlet UISwitch* checkbox1;
@property (assign) IBOutlet UISwitch* checkbox2;
@property (assign) IBOutlet UISwitch* checkbox3;

- (IBAction) sliderChanged:(id)sender;
- (IBAction) datePickerChanged:(id)sender;
- (IBAction) switch1Changed:(id)sender;
- (IBAction) switch2Changed:(id)sender;
- (IBAction) switch3Changed:(id)sender;
- (void) showPeers;

@end
