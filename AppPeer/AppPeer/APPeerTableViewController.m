//
//  APPeerTableViewController.m
//  AppPeer
//
//  Created by Gabriel Lumbi on 12/3/2013.
//  Copyright (c) 2013 Wherecloud Inc. All rights reserved.
//

#import "APPeerTableViewController.h"
#import "APPeerSource.h"

@interface APPeerTableViewController (){
    APPeerSource* _peerSource;
}

@end

@implementation APPeerTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

-(id)initWithHub:(APHub*)hub{
    if(self = [self initWithStyle:UITableViewStylePlain]){
        self.hub = hub;
        self.tableView.allowsSelection = YES;
        self.tableView.allowsMultipleSelection = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.hub.availablePeers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"peer_table_";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    APPeer* peer = [self.hub.availablePeers objectAtIndex:indexPath.row];
    
    cell.textLabel.text = peer.name;
    
    if([self.hub.connectedPeers containsObject:peer]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    APPeer* peer = [self.hub.availablePeers objectAtIndex:indexPath.row];
    if(![self.hub.connectedPeers containsObject:peer]){
        [self.hub connectToPeer:peer];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}

@end
