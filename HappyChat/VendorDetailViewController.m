//
//  VendorDetailViewController.m
//  HappyChat
//
//  Created by Alex Johnson on 8/06/2016.
//  Copyright (c) 2016 NikolaiTomov. All rights reserved.
//

#import "VendorDetailViewController.h"
#import "ChatTableViewCell.h"

@interface VendorDetailViewController ()

@end

@implementation VendorDetailViewController

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"chatCell";
    ChatTableViewCell *cell = (ChatTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    return cell;
}

@end
