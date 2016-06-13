//
//  VendorSelectViewController.m
//  HappyChat
//
//  Created by Alex Johnson on 8/06/2016.
//  Copyright (c) 2016 NikolaiTomov. All rights reserved.
//

#import "VendorSelectViewController.h"
#import "VendorTableViewCell.h"
#import "Session.h"

@interface VendorSelectViewController ()

@end

@implementation VendorSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255.0/255 green:132.0/255 blue:0.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSideMenu:(UIBarButtonItem *)sender {
    if(![Session isLoggedIn])
        [self performSegueWithIdentifier:@"showLoginSideMenuSegue" sender:self];
    else
        [self performSegueWithIdentifier:@"showUserSideMenuSegue" sender:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"vendorCell";
    VendorTableViewCell *cell = (VendorTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    return cell;
}
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition {
    static NSString *moveToDetailId = @"moveToDetail";
    [self performSegueWithIdentifier:moveToDetailId sender:self];
}
@end
