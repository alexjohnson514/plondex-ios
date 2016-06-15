//
//  VendorDashboardViewController.m
//  HappyChat
//
//  Created by Alex Johnson on 13/06/2016.
//  Copyright © 2016 NikolaiTomov. All rights reserved.
//

#import "VendorDashboardViewController.h"
#import "WaitingTableViewCell.h"
#import "ChatTableViewCell.h"
#import "Session.h"
#import "Const.h"
#import "AppDelegate.h"

@interface VendorDashboardViewController ()

// Properties
@property (strong, nonatomic) AppDelegate *gApp;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableDictionary *peers;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (strong, nonatomic) UIView *peerVideoView;
@property (strong, nonatomic) UIView *userVideoView;
@property (strong, nonatomic) NSString *roomName;
@property (strong, nonatomic) SKYLINKConnection* skylinkConnection;

@end

@implementation VendorDashboardViewController
@synthesize gApp;
@synthesize indicator;
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
    
    self.vendorName.text = [NSString stringWithFormat:@"%@ %@", [[Session loginData] objectForKey:KEY_USER_FIRSTNAME], [[Session loginData] objectForKey:KEY_USER_LASTNAME]];
    self.vendorCost.text = [NSString stringWithFormat:@"%@ pts/min", [[Session loginData] objectForKey:KEY_USER_COST]];
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.frame = self.view.bounds;
    indicator.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    indicator.hidesWhenStopped = YES;
    
    [self.view addSubview:indicator];
    [indicator startAnimating];
    
    self.waitingList = [[NSMutableArray alloc] initWithArray:@[]];
    self.messages = [[NSMutableArray alloc] initWithArray:@[]];
    self.peers = [[NSMutableDictionary alloc] initWithDictionary:@{}];
    self.roomName = [NSString stringWithFormat:@"room_%@", [[Session loginData] objectForKey:KEY_USER_ID]];}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString* name = [NSString stringWithFormat:@"%@ %@", [[Session loginData] objectForKey:KEY_USER_FIRSTNAME], [[Session loginData] objectForKey:KEY_USER_LASTNAME]];
    NSString* photo = [NSString stringWithFormat:@"https://plondex.com/photo/user/%@/50/50/1", [[Session loginData] objectForKey:KEY_USER_ID]];
    NSString* uid = [[Session loginData] objectForKey:KEY_USER_ID];
    self.vendorName.text = name;
    self.vendorCost.text = [NSString stringWithFormat:@"%@ pts/min", [[Session loginData] objectForKey:KEY_USER_COST]];
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.waitingTable)
        return self.waitingList.count;
    else
        return self.messages.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.waitingTable) {
        static NSString *cellIdentifier1 = @"waitingCell";
        WaitingTableViewCell *cell = (WaitingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        cell.peerId = self.waitingList[indexPath.row];
        NSDictionary* peer = [self.peers objectForKey:cell.peerId];
        cell.name.text = [peer objectForKey:@"name"];
        return cell;
    } else {
        static NSString *cellIdentifier2 = @"chatCell";
        ChatTableViewCell *cell = (ChatTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        NSDictionary* peer = [self.peers objectForKey:[self.messages[indexPath.row] objectForKey:@"peerId"]];
        cell.name.text = [peer objectForKey:@"name"];
        if(peer == nil)
            cell.name.text = @"You";
        cell.message.text = [self.messages[indexPath.row] objectForKey:@"message"];
        return cell;
    }
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
    if([message length] > 4 && [[message substringToIndex:5] isEqualToString:@"[vtr]"]) {
        [self.waitingList addObject:peerId];
        [self.waitingTable reloadData];
    } else {
        [self.messages addObject:@{@"message" : message,
                                      @"isPublic" : [NSNumber numberWithBool:isPublic],
                                      @"peerId" : peerId,
                                      @"type" : @"P2P"
                                      }];
        [self.chatTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade]; // equivalent of [self.tableView reloadData]; + [self.tableView scrollsToTop]; but with an animation
    }
}

#pragma mark - SKYLINKConnectionRemotePeerDelegate

- (void)connection:(SKYLINKConnection*)connection didJoinPeer:(id)userInfo mediaProperties:(SKYLINKPeerMediaProperties*)pmProperties peerId:(NSString*)peerId {
    [self.peers addEntriesFromDictionary:@{peerId:userInfo}];}

- (void)connection:(SKYLINKConnection*)connection didReceiveUserInfo:(id)userInfo peerId:(NSString*)peerId {
    [self.peers removeObjectForKey:peerId];
    [self.peers addEntriesFromDictionary:@{peerId:userInfo}];
    [self.chatTable reloadData]; // will reload the sender label
}

- (void)connection:(SKYLINKConnection*)connection didLeavePeerWithMessage:(NSString*)errorMessage peerId:(NSString*)peerId {
    NSLog(@"Peer with ID %@ left with message: %@", peerId, errorMessage);
    [self.peers removeObjectForKey:peerId];
    [self.waitingList removeObject:peerId];
    [self.waitingTable reloadData];
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
    UIButton* button = (UIButton*)sender;
    WaitingTableViewCell* cell = (WaitingTableViewCell*)[[button superview] superview];
    NSString* peerId = cell.peerId;
    
    NSString *createConvUrl = [[NSString stringWithFormat:@"https://plondex.com/Convo/createConvo/%@/%@", [[self.peers objectForKey:peerId] objectForKey:@"id"], [[Session loginData] objectForKey:KEY_USER_ID]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:createConvUrl]];
    [urlRequest setTimeoutInterval:30];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSLog(@"Nikolai : %s begin.", __FUNCTION__);
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [indicator stopAnimating];
        if (connectionError) {
            NSLog(@"Nikolai : Create Conv Failed.");
        }
        else{
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"Nikolai : Create Conv Successful.");
            NSString *message = [NSString stringWithFormat:@"[accept]%@", jsonObject[KEY_CONVO_ID]];
            [self.skylinkConnection sendDCMessage:message peerId:peerId];
            gApp.videoRoom = jsonObject[KEY_CONVO_ID];
            [self.skylinkConnection disconnect:^{
                [self performSegueWithIdentifier:@"moveToVideoFromVendor" sender:self];
            }];
        }
    }];
}

-(void)sendMessage:(NSString *)message forPeerId:(NSString *)peerId { // nil peerId means public message
    
    [self.skylinkConnection sendDCMessage:message peerId:peerId];
    
    self.messageTextField.text = @"";
    [self.messages insertObject:@{@"message" : message,
                                  @"isPublic" :[NSNumber numberWithBool:(!peerId)],
                                  @"peerId" : self.skylinkConnection.myPeerId}
                        atIndex:0];
    [self.chatTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.messageTextField resignFirstResponder];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed. return NO to ignore.
{
    return [textField resignFirstResponder];
}

@end
