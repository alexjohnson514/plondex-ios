//
//  SideMenuUserViewController.m
//  Chatbrities
//
//  Created by Alex Johnson on 13/06/2016.
//  Copyright © 2016 NikolaiTomov. All rights reserved.
//

#import "SideMenuUserViewController.h"
#import "Session.h"
#import "VendorDetailViewController.h"

@implementation SideMenuUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    self.view.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width, 20.0);
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // Grow!
                         self.view.transform = CGAffineTransformMakeTranslation(0.0, 20.0);
                     }
                     completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onOutsideTouch:(id)sender {
    [UIView animateWithDuration:0.5f delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect newframe = self.view.frame;
        newframe.origin.x = -newframe.size.width;
        self.view.frame = newframe;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}
- (IBAction)onBrowseVendors:(id)sender {
    UINavigationController* parentController = ((UINavigationController*)self.presentingViewController);
    [self dismissViewControllerAnimated:NO completion:nil];
    if([parentController.topViewController isMemberOfClass:[VendorDetailViewController class]]) {
        [parentController popViewControllerAnimated:NO];
    }
}
- (IBAction)onMyAccount:(id)sender {
}
- (IBAction)onBuyPoints:(id)sender {
}
- (IBAction)onLogout:(id)sender {
    UINavigationController* parentController = ((UINavigationController*)self.presentingViewController);
    [self dismissViewControllerAnimated:NO completion:nil];
    [parentController popViewControllerAnimated:NO];
    [Session logout];
}

@end
