//
//  VendorDetailViewController.h
//  HappyChat
//
//  Created by Alex Johnson on 8/06/2016.
//  Copyright (c) 2016 NikolaiTomov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SKYLINK/SKYLINK.h>


@interface VendorDetailViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, SKYLINKConnectionLifeCycleDelegate, SKYLINKConnectionMessagesDelegate, SKYLINKConnectionRemotePeerDelegate, SKYLINKConnectionMediaDelegate>
@property (weak, nonatomic) IBOutlet UIView *vendorDetailBar;
@property (strong, nonatomic) NSString *roomName;

@end
