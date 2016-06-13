//
//  ChatViewController.m
//  HappyChat
//
//  Created by Alex Johnson on 12/06/2016.
//  Copyright © 2016 NikolaiTomov. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onCloseChatTapped:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)addUserVideoView:(UIView*)view {
    [self.view addSubview:view];
    view.frame = self.view.frame;
}
- (void)addPeerVideoView:(UIView*)view {
    [self.view addSubview:view];
    view.frame = CGRectMake(self.view.frame.origin.x+self.view.frame.size.width - 240, self.view.frame.origin.y+self.view.frame.size.height - 320, 240, 320);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
