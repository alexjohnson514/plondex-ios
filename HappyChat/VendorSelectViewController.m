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
#import "Const.h"

@interface VendorSelectViewController ()

@end

@implementation VendorSelectViewController
@synthesize indicator;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.frame = self.view.bounds;
    indicator.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    indicator.hidesWhenStopped = YES;
    
    [self.view addSubview:indicator];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255.0/255 green:132.0/255 blue:0.0 alpha:1.0];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.vendorList = [[NSMutableArray alloc] init];
    [indicator startAnimating];
    
    NSString *vendorListUrl = [[NSString stringWithFormat:@"%@/%@/%@/%@?keygen=%@", SERVER_URL, API_GET_VENDORS, @0, @0, AUTH_KEYGEN] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    vendorListUrl = [vendorListUrl stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:vendorListUrl]];
    [urlRequest setTimeoutInterval:30];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSLog(@"Nikolai : %s begin.", __FUNCTION__);
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [indicator stopAnimating];
        if (connectionError) {
            NSLog(@"Nikolai : Get Vendor List Failed.");
        }
        else{
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([jsonObject[KEY_SUCCESS] intValue] == 1) {
                NSLog(@"Nikolai : Get Vendor List Failed, %@",  jsonObject[KEY_MESSAGE]);
            }
            else{
                NSLog(@"Nikolai : Get Vendor List Successful.");
                [self.vendorList addObjectsFromArray:jsonObject[KEY_DATA]];
                [self.vendorListView reloadData];
            }
        }
    }];
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
    return self.vendorList.count;
}
// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"vendorCell";
    VendorTableViewCell *cell = (VendorTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.vendorName.text = [NSString stringWithFormat:@"%@ %@", [self.vendorList[indexPath.row] objectForKey:KEY_USER_FIRSTNAME], [self.vendorList[indexPath.row] objectForKey:KEY_USER_LASTNAME]];
    cell.vendorCost.text = [NSString stringWithFormat:@"%@ pts/min", [self.vendorList[indexPath.row] objectForKey:KEY_USER_COST]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *loginVendorSegue = @"loginVendorSegue";
    [self performSegueWithIdentifier:loginVendorSegue sender:self];
}
@end
