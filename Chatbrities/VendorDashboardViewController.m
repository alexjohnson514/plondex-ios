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

@implementation VendorDashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.waitingTable)
        return self.waitingList.count;
    else
        return 3;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.waitingTable) {
        static NSString *cellIdentifier1 = @"waitingCell";
        WaitingTableViewCell *cell = (WaitingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        return cell;
    } else {
        static NSString *cellIdentifier2 = @"chatCell";
        ChatTableViewCell *cell = (ChatTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        return cell;
    }
}



@end
