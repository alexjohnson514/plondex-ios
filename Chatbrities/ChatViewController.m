//
//  ChatViewController.m
//  HappyChat
//
//  Created by Alex Johnson on 12/06/2016.
//  Copyright © 2016 NikolaiTomov. All rights reserved.
//

#import "ChatViewController.h"
#import "AppDelegate.h"
#import "Const.h"

@interface ChatViewController ()
@property (strong, nonatomic) AppDelegate *gApp;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) SKYLINKConnection *skylinkConnection;

@end

@implementation ChatViewController
@synthesize activityIndicator;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.frame = self.view.bounds;
    activityIndicator.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    activityIndicator.hidesWhenStopped = YES;
    
    [self.view addSubview:activityIndicator];

}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.gApp = [UIApplication sharedApplication].delegate;
    [activityIndicator startAnimating];
    
    // Creating configuration
    SKYLINKConnectionConfig *config = [SKYLINKConnectionConfig new];
    config.video = YES;
    config.audio = YES;
    // Creating SKYLINKConnection
    self.skylinkConnection = [[SKYLINKConnection alloc] initWithConfig:config appKey:CONSTANT_SKYLINK_APP_KEY];
    self.skylinkConnection.lifeCycleDelegate = self;
    self.skylinkConnection.mediaDelegate = self;
    self.skylinkConnection.remotePeerDelegate = self;
    // Connecting to a room
    [SKYLINKConnection setVerbose:TRUE];
    [self.skylinkConnection connectToRoomWithSecret:CONSTANT_SKYLINK_SECRET roomName:[NSString stringWithFormat:@"private_room_%@",self.gApp.videoRoom] userInfo:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onCloseChatTapped:(id)sender {
    [self.skylinkConnection disconnect:^{
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)addUserVideoView:(UIView*)view {
    [self.view insertSubview:view atIndex:0];
    view.frame = CGRectMake(view.frame.size.width - 140, view.frame.size.height - 180, 120, 160);
}

- (void)addPeerVideoView:(UIView*)view {
    [self.view insertSubview:view atIndex:0];
    view.frame = self.view.frame;
}

#pragma mark - SKYLINKConnectionLifeCycleDelegate
- (void)connection:(SKYLINKConnection *)connection didLockTheRoom:(BOOL)lockStatus peerId:(NSString *)peerId {}

- (void)connection:(SKYLINKConnection*)connection didConnectWithMessage:(NSString*)errorMessage success:(BOOL)isSuccess {
    if (isSuccess) {
        NSLog(@"Inside %s", __FUNCTION__);
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Connection failed" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
    });
}

- (void)connection:(SKYLINKConnection*)connection didRenderUserVideo:(UIView*)userVideoView {
    [self addUserVideoView:userVideoView];
}

- (void)connection:(SKYLINKConnection*)connection didDisconnectWithMessage:(NSString*)errorMessage {
    [[[UIAlertView alloc] initWithTitle:@"Disconnected" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    [self.activityIndicator stopAnimating];
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - SKYLINKConnectionRemotePeerDelegate

- (void)connection:(SKYLINKConnection*)connection didJoinPeer:(id)userInfo mediaProperties:(SKYLINKPeerMediaProperties*)pmProperties peerId:(NSString*)peerId {
    NSLog(@"Peer with id %@ joined the room", peerId);
}

- (void)connection:(SKYLINKConnection*)connection didLeavePeerWithMessage:(NSString*)errorMessage peerId:(NSString*)peerId {
    NSLog(@"Peer with id %@ left the room with message: %@", peerId, errorMessage);
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)connection:(SKYLINKConnection*)connection didRenderPeerVideo:(UIView*)peerVideoView peerId:(NSString*)peerId {
    [self addPeerVideoView:peerVideoView];
}

#pragma mark - SKYLINKConnectionMediaDelegate
- (void)connection:(SKYLINKConnection*)connection didChangeVideoSize:(CGSize)videoSize videoView:(UIView*)videoView
{
}

- (void)connection:(SKYLINKConnection *)connection didToggleAudio:(BOOL)isMuted peerId:(NSString *)peerId {}

- (void)connection:(SKYLINKConnection *)connection didToggleVideo:(BOOL)isMuted peerId:(NSString *)peerId {}

@end
