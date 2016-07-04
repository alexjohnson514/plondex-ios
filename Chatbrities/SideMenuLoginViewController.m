//
//  SideMenuLoginViewController.m
//  Chatbrities
//
//  Created by Alex Johnson on 11/06/2016.
//  Copyright © 2016 NikolaiTomov. All rights reserved.
//

#import "SideMenuLoginViewController.h"
#import "VendorSelectViewController.h"
#import "Const.h"
#import "Session.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>

@interface SideMenuLoginViewController ()
@end
@implementation SideMenuLoginViewController
@synthesize indicator;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.frame = self.view.bounds;
    indicator.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    indicator.hidesWhenStopped = YES;
    
    [self.view addSubview:indicator];
}

- (void)viewWillAppear:(BOOL)animated {
    self.view.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width, 20.0);
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // Grow!
                         self.view.transform = CGAffineTransformMakeTranslation(0.0, 20.0);
                     }
                     completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onOutsideTouch:(id)sender {
    [UIView animateWithDuration:0.5f delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect newframe = self.view.frame;
        newframe.origin.x = -newframe.size.width;
        self.view.frame = newframe;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}
#pragma mark Login Actions
- (IBAction)onFBLogin:(id)sender {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"email"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Process error occurred during facebook login" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
         } else if (result.isCancelled) {
             [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Process cancelled during facebook login" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
         } else {
             //Login success
             [self postFBLoginActionWithResult: result];
         }
     }];
}

- (void)postFBLoginActionWithResult: (FBSDKLoginManagerLoginResult*) result {
    NSString* uid = [[result token] userID];
    NSString* token = [[result token] tokenString];
    [indicator startAnimating];
    
    NSLog(@"Nikolai : %s begin.", __FUNCTION__);
    
    //Get user profile from facebook
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:[NSString stringWithFormat:@"/%@", uid]
                                  parameters:@{@"fields": @"id, email, first_name, last_name, picture, is_verified, verified"}
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        // Handle the result
        if(error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to get profile" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            [indicator stopAnimating];
        } else {    //Success getting profile
            
            NSString* first_name = [result objectForKey:@"first_name"];
            NSString* last_name = [result objectForKey:@"last_name"];
            NSString* picture = [[[result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
            NSString* email = [result objectForKey:@"email"];
            id is_verified = [result objectForKey:@"is_verified"];
            id verified = [result objectForKey:@"verified"];
            NSString* pictureEnc = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                            NULL,
                                                                                            (CFStringRef)picture,
                                                                                            NULL,
                                                                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                            kCFStringEncodingUTF8 ));
            //Start getting User by facebook id
            NSString *getUserByFBUrl = [[NSString stringWithFormat:@"%@%@/%@?keygen=%@", SERVER_URL, API_GET_USER_BY_FACEBOOK_ID, uid, AUTH_KEYGEN] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            getUserByFBUrl = [getUserByFBUrl stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
            
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:getUserByFBUrl]];
            [urlRequest setTimeoutInterval:30];
            [urlRequest setHTTPMethod:@"GET"];
            
            [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (connectionError) {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to check user existence." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    [indicator stopAnimating];
                }
                else{
                    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                    if ([jsonObject[KEY_SUCCESS] intValue] != 1) {
                        NSLog(@"Nikolai : No FB user exist. Creating new user, %@",  jsonObject[KEY_MESSAGE]);
                        
                        //Start creating user using facebook profile
                        NSString *createFBUserUrl = [[NSString stringWithFormat:@"%@%@/%@/%@/%@/%@/%@/%@/%ld/%ld?keygen=%@", SERVER_URL, API_CREATE_FACEBOOK_USER, email ?: @"", uid, first_name ?: @"", last_name ?: @"", @0, pictureEnc ?: @"", (long)verified, (long)is_verified, AUTH_KEYGEN] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        createFBUserUrl = [createFBUserUrl stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
                        
                        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:createFBUserUrl]];
                        [urlRequest setTimeoutInterval:30];
                        [urlRequest setHTTPMethod:@"GET"];
                        
                        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                            [indicator stopAnimating];
                            if (connectionError) {
                                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to sign up." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                [indicator stopAnimating];

                            }
                            else{
                                NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                if ([jsonObject[KEY_SUCCESS] intValue] != 1) {
                                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to sign up." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                    [indicator stopAnimating];
                                }
                                else{
                                    [Session setLoginDataWithData: @{
                                                                     KEY_USER_ID: [jsonObject objectForKey:KEY_DATA],
                                                                     KEY_USER_FIRSTNAME: first_name,
                                                                     KEY_USER_LASTNAME: last_name,
                                                                     KEY_USER_GROUP: @0,
                                                                     KEY_USER_EMAIL: email,
                                                                     KEY_USER_PIC: picture,
                                                                     KEY_USER_IS_VERIFIED: is_verified
                                                                     }];
                                    [indicator stopAnimating];
                                    [self dismissViewControllerAnimated:NO completion:nil];
                                }
                            }
                        }];
                    }
                    else{
                        [Session setLoginDataWithData: [jsonObject objectForKey:KEY_DATA]];
                        [indicator stopAnimating];
                        [self dismissViewControllerAnimated:NO completion:nil];
                    }
                }
            }];
        }
    }];
}
- (IBAction)onTwitterLogin:(id)sender {
}

#pragma mark Prevent Screen Orientation
-(BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


@end
