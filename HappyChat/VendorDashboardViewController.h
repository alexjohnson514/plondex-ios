//
//  VendorDashboardViewController.h
//  HappyChat
//
//  Created by Alex Johnson on 13/06/2016.
//  Copyright © 2016 NikolaiTomov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VendorDashboardViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *vendorDetailBar;
@property (weak, nonatomic) IBOutlet UITableView *waitingTable;
@property (weak, nonatomic) IBOutlet UITableView *chatTable;
@property (weak, nonatomic) IBOutlet UILabel *vendorName;
@property (weak, nonatomic) IBOutlet UILabel *vendorPoint;
@property (weak, nonatomic) IBOutlet UIImageView *vendorImage;
@property (strong, nonatomic) NSMutableArray *waitingList;

@end