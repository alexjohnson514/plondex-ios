//
//  SideMenuLoginViewController.h
//  Chatbrities
//
//  Created by Alex Johnson on 11/06/2016.
//  Copyright © 2016 NikolaiTomov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenuLoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@end
