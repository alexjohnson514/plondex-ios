//
//  SideMenuLoginViewController.m
//  Chatbrities
//
//  Created by Alex Johnson on 11/06/2016.
//  Copyright © 2016 NikolaiTomov. All rights reserved.
//

#import "SideMenuLoginViewController.h"
#import "VendorSelectViewController.h"
#import "Const.h"
#import "Session.h"

@interface SideMenuLoginViewController ()
@end
@implementation SideMenuLoginViewController
@synthesize indicator;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.frame = self.view.bounds;
    indicator.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    indicator.hidesWhenStopped = YES;
    
    [self.view addSubview:indicator];
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
#pragma mark Login Actions
- (IBAction)onFBLogin:(id)sender {
}
- (IBAction)onTwitterLogin:(id)sender {
}

#pragma mark Prevent Screen Orientation
-(BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


@end
