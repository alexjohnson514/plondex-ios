//
//  VendorDetailViewController.h
//  Chatbrities
//
//  Created by Alex Johnson on 8/06/2016.
//  Copyright (c) 2016 NikolaiTomov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SKYLINK/SKYLINK.h>


@interface VendorDetailViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, SKYLINKConnectionLifeCycleDelegate, SKYLINKConnectionMessagesDelegate, SKYLINKConnectionRemotePeerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *vendorDetailBar;

@end
