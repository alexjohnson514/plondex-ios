//
//  VendorSelectViewController.h
//  HappyChat
//
//  Created by Alex Johnson on 8/06/2016.
//  Copyright (c) 2016 NikolaiTomov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VendorSelectViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (strong, nonatomic) NSMutableArray *vendorList;
@property (weak, nonatomic) IBOutlet UITableView *vendorListView;

@end
