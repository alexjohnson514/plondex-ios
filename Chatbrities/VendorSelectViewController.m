//
//  VendorSelectViewController.m
//  Chatbrities
//
//  Created by Alex Johnson on 8/06/2016.
//  Copyright (c) 2016 NikolaiTomov. All rights reserved.
//

#import "VendorSelectViewController.h"
#import "VendorTableViewCell.h"
#import "Session.h"
#import "Const.h"

@interface VendorSelectViewController ()
{
    bool no_more;
}
@property (strong, nonatomic) UIImageView* profileImageView;
@end

@implementation VendorSelectViewController
@synthesize indicator;
@synthesize profileImageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    no_more = NO;
    
    // Do any additional setup after loading the view.
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.frame = self.view.bounds;
    indicator.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    indicator.hidesWhenStopped = YES;
    
    [self.view addSubview:indicator];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    
    if([Session isLoggedIn] && [[[Session loginData] objectForKey:KEY_USER_GROUP] isEqualToString:USERTYPE_VENDOR])
    {
        [self performSegueWithIdentifier:@"loginVendorSegue" sender:self];
    }
    
    self.vendorPhotoCache = [[NSMutableDictionary alloc] init];
    [self performSelectorInBackground:@selector(loadToolbarImage) withObject:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    profileImageView = self.navigationItem.titleView.subviews[0];
    profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2;
    
    self.vendorList = [[NSMutableArray alloc] init];
    [self loadVendors];
    
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
    cell.vendorId = [self.vendorList[indexPath.row] objectForKey:KEY_USER_ID];
    cell.vendorPhoto.image = [UIImage imageNamed:@"vendor_photo"];
    [self performSelectorInBackground:@selector(loadImage:) withObject:cell];
    cell.vendorName.text = [NSString stringWithFormat:@"%@ %@", [self.vendorList[indexPath.row] objectForKey:KEY_USER_FIRSTNAME], [self.vendorList[indexPath.row] objectForKey:KEY_USER_LASTNAME]];
    NSString* cost = [self.vendorList[indexPath.row] objectForKey:KEY_USER_COST];
    if (cost == nil || cost == (id)[NSNull null]) cost = @"0";
    cell.vendorCost.text = [NSString stringWithFormat:@"%@ pts/min", cost];
    return cell;
}
- (void)loadToolbarImage {
    if(![Session isLoggedIn]) return;
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/profile%@", documentPath, [[Session loginData] objectForKey:KEY_USER_ID]];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        UIImage* image = [[UIImage alloc] initWithContentsOfFile:filePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            profileImageView.image = image;
        });
    } else {
        NSData *data = [[NSData alloc] initWithContentsOfURL:[[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@/%@/50/50/1", SERVER_URL, API_PHOTO, [[Session loginData] objectForKey:KEY_USER_ID]]]];
        UIImage* image = [[UIImage alloc] initWithData:data];
        
        if(image==nil) {
            image = [UIImage imageNamed:@"vendor_photo"];
            CGDataProviderRef provider = CGImageGetDataProvider(image.CGImage);
            data = (id)CFBridgingRelease(CGDataProviderCopyData(provider));
        }
        [data writeToFile:filePath atomically:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            profileImageView.image = image;
        });
    }
}
- (void)loadImage:(VendorTableViewCell*)cell {
    NSString* vendorId = cell.vendorId;
    UIImageView* vendorPhoto = cell.vendorPhoto;
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentPath, vendorId];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSData *data = [[NSData alloc] initWithContentsOfURL:[[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@/%@/%d/%d/1", SERVER_URL, API_PHOTO, vendorId, (int)vendorPhoto.frame.size.width, (int)vendorPhoto.frame.size.height]]];
        UIImage* image = [[UIImage alloc] initWithData:data];
        
        if(image==nil) {
            image = [UIImage imageNamed:@"vendor_photo"];
            data = UIImagePNGRepresentation(image);
        }
        [data writeToFile:filePath atomically:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            if([vendorId isEqualToString:cell.vendorId])
                vendorPhoto.image = image;
        });
    } else {
        UIImage* image;
        image = [[UIImage alloc] initWithContentsOfFile:filePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            vendorPhoto.image = image;
        });
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [Session setSelectedVendor:self.vendorList[indexPath.row]];
    [self performSegueWithIdentifier:@"loginUserSegue" sender:self];
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if(scrollView.contentOffset.y + scrollView.bounds.size.height> scrollView.contentSize.height && no_more == NO) {
        [self loadVendors];
    }
}

- (void)loadVendors {
    [indicator startAnimating];
    
    NSString *vendorListUrl = [[NSString stringWithFormat:@"%@%@/%d/%d?keygen=%@", SERVER_URL, API_GET_VENDORS, self.vendorList.count, REQUEST_COUNT, AUTH_KEYGEN] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
            if ([jsonObject[KEY_SUCCESS] intValue] != 1) {
                NSLog(@"Nikolai : Get Vendor List Failed, %@",  jsonObject[KEY_MESSAGE]);
            }
            else{
                NSLog(@"Nikolai : Get Vendor List Successful.");
                [self.vendorList addObjectsFromArray:jsonObject[KEY_DATA]];
                [self.vendorListView reloadData];
                if([jsonObject[KEY_DATA] count] < REQUEST_COUNT) no_more = YES;
            }
        }
    }];
}
@end
