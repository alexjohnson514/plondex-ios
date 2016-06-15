//
//  VendorDetailViewController.m
//  HappyChat
//
//  Created by Alex Johnson on 8/06/2016.
//  Copyright (c) 2016 NikolaiTomov. All rights reserved.
//

#import "VendorDetailViewController.h"
#import "ChatTableViewCell.h"
#import "Const.h"
#import "AppDelegate.h"
#import "Session.h"

@interface VendorDetailViewController ()

// Properties
@property (strong, nonatomic) AppDelegate *gApp;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableDictionary *peers;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *vendorName;
@property (weak, nonatomic) IBOutlet UILabel *vendorCost;
@property (weak, nonatomic) IBOutlet UIButton *talkButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) SKYLINKConnection* skylinkConnection;

@property (strong, nonatomic) NSString *roomName;

@end

@implementation VendorDetailViewController
@synthesize indicator;
@synthesize gApp;

- (void)viewDidLoad {
    [super viewDidLoad];
    gApp = [UIApplication sharedApplication].delegate;

    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.vendorDetailBar.bounds];
    self.vendorDetailBar.layer.masksToBounds = NO;
    self.vendorDetailBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.vendorDetailBar.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.vendorDetailBar.layer.shadowOpacity = 0.5f;
    self.vendorDetailBar.layer.shadowPath = shadowPath.CGPath;
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.frame = self.view.bounds;
    indicator.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    indicator.hidesWhenStopped = YES;
    
    [self.view addSubview:indicator];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [indicator startAnimating];
    self.vendorName.text = [NSString stringWithFormat:@"%@ %@", [[Session selectedVendor] objectForKey:KEY_USER_FIRSTNAME], [[Session selectedVendor] objectForKey:KEY_USER_LASTNAME]];
    self.vendorCost.text = [NSString stringWithFormat:@"%@ pts/min", [[Session selectedVendor] objectForKey:KEY_USER_COST]];
    self.messages = [[NSMutableArray alloc] initWithArray:@[]];
    self.peers = [[NSMutableDictionary alloc] initWithDictionary:@{}];
    self.roomName = [NSString stringWithFormat:@"room_%@", [[Session selectedVendor] objectForKey:KEY_USER_ID]];
    NSString* name = [NSString stringWithFormat:@"%@ %@", [[Session loginData] objectForKey:KEY_USER_FIRSTNAME], [[Session loginData] objectForKey:KEY_USER_LASTNAME]];
    NSString* photo = [NSString stringWithFormat:@"https://plondex.com/photo/user/%@/50/50/1", [[Session loginData] objectForKey:KEY_USER_ID]];
    NSString* uid = [[Session loginData] objectForKey:KEY_USER_ID];
    // Creating configuration
    SKYLINKConnectionConfig *config = [SKYLINKConnectionConfig new];
    config.video = NO;
    config.audio = NO;
    config.fileTransfer = NO;
    config.dataChannel = YES; // for data chanel messages
    
    // Creating SKYLINKConnection
    
    self.skylinkConnection = [[SKYLINKConnection alloc] initWithConfig:config appKey:CONSTANT_SKYLINK_APP_KEY];
    self.skylinkConnection.lifeCycleDelegate = self;
    self.skylinkConnection.messagesDelegate = self;
    self.skylinkConnection.remotePeerDelegate = self;
    // Connecting to a room
    [SKYLINKConnection setVerbose:TRUE];
    NSDictionary* userInfo = @{
                               @"name": name,
                               @"photo": photo,
                               @"id": uid
                               };
    [self.skylinkConnection connectToRoomWithSecret:CONSTANT_SKYLINK_SECRET roomName:self.roomName userInfo:userInfo]; // a nickname could be sent here via userInfo cf the implementation of - (void)connection:(SKYLINKConnection*)connection didJoinPeer:(id)userInfo mediaProperties:(SKYLINKPeerMediaProperties*)pmProperties peerId:(NSString*)peerId
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"chatCell";
    ChatTableViewCell *cell = (ChatTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSDictionary* peer = [self.peers objectForKey:[self.messages[indexPath.row] objectForKey:@"peerId"]];
    cell.name.text = [peer objectForKey:@"name"];
    if(peer == nil)
        cell.name.text = @"You";
    cell.message.text = [self.messages[indexPath.row] objectForKey:@"message"];
    return cell;
}

#pragma mark - SKYLINKConnectionLifeCycleDelegate

- (void)connection:(SKYLINKConnection*)connection didConnectWithMessage:(NSString*)errorMessage success:(BOOL)isSuccess {
    if (isSuccess) {
        NSLog(@"Inside %s", __FUNCTION__);
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Connection failed" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [self.navigationController popViewControllerAnimated:YES];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.indicator stopAnimating];
    });
}

- (void)connection:(SKYLINKConnection*)connection didDisconnectWithMessage:(NSString*)errorMessage {
    [[[UIAlertView alloc] initWithTitle:@"Disconnected" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - SKYLINKConnectionMessagesDelegate

- (void)connection:(SKYLINKConnection*)connection didReceiveDCMessage:(id)message public:(BOOL)isPublic peerId:(NSString*)peerId {
    if([message length]>7 && [[message substringToIndex:8] isEqualToString:@"[accept]"]) {
        NSString* videoRoom = [message substringFromIndex:8];
        gApp.videoRoom = videoRoom;
        [self.skylinkConnection disconnect:^{
            [self performSegueWithIdentifier:@"moveToVideo" sender:self];
        }];
    } else {
        [self.messages addObject:@{@"message" : message,
                                  @"isPublic" : [NSNumber numberWithBool:isPublic],
                                  @"peerId" : peerId,
                                  @"type" : @"P2P"
                                  }];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade]; // equivalent of [self.tableView reloadData]; + [self.tableView scrollsToTop]; but with an animation
    }
}

#pragma mark - SKYLINKConnectionRemotePeerDelegate

- (void)connection:(SKYLINKConnection*)connection didJoinPeer:(id)userInfo mediaProperties:(SKYLINKPeerMediaProperties*)pmProperties peerId:(NSString*)peerId {
    [self.peers addEntriesFromDictionary:@{peerId:userInfo}];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.talkButton.enabled = YES;
    });
}

- (void)connection:(SKYLINKConnection*)connection didReceiveUserInfo:(id)userInfo peerId:(NSString*)peerId {
    [self.peers removeObjectForKey:peerId];
    [self.peers addEntriesFromDictionary:@{peerId:userInfo}];
    [self.tableView reloadData]; // will reload the sender label
}

- (void)connection:(SKYLINKConnection*)connection didLeavePeerWithMessage:(NSString*)errorMessage peerId:(NSString*)peerId {
    NSLog(@"Peer with ID %@ left with message: %@", peerId, errorMessage);
    [self.peers removeObjectForKey:peerId];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.talkButton.enabled = NO;
    });

}

-(IBAction)processMessage:(id)sender {
    if (self.messageTextField.text.length > 0) {
        NSString *message = self.messageTextField.text;
        [self sendMessage:message forPeerId:nil];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Empty message" message:@"\nType the message to be sent." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
}

-(IBAction)talkTap:(id)sender {
    NSString *message = [NSString stringWithFormat:@"[vtr]%@", 
self.skylinkConnection.myPeerId];
    [self.skylinkConnection sendDCMessage:message peerId:nil];
}

-(void)sendMessage:(NSString *)message forPeerId:(NSString *)peerId { // nil peerId means public message
    [self.skylinkConnection sendDCMessage:message peerId:peerId];
    self.messageTextField.text = @"";
    [self.messages insertObject:@{@"message" : message,
                                      @"isPublic" :[NSNumber numberWithBool:(!peerId)],
                                      @"peerId" : self.skylinkConnection.myPeerId}
                            atIndex:0];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.messageTextField resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed. return NO to ignore.
{
    return [textField resignFirstResponder];
}


@end
