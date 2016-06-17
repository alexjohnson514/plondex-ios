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
- (IBAction)onLogin:(id)sender {
    [indicator startAnimating];
    [self.view endEditing:YES];
    NSString *loginUrl = [[NSString stringWithFormat:@"%@/%@/%@/%@?keygen=%@", SERVER_URL, API_LOGIN, _txtEmail.text,_txtPassword.text, AUTH_KEYGEN] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    loginUrl = [loginUrl stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:loginUrl]];
    [urlRequest setTimeoutInterval:30];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSLog(@"Nikolai : %s begin.", __FUNCTION__);
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [indicator stopAnimating];
        if (connectionError) {
            [[[UIAlertView alloc] initWithTitle:@"Login failed" message:@"Can't connect to server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            NSLog(@"Nikolai : Login Failed.");
        }
        else{
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([jsonObject[KEY_SUCCESS] intValue] != 1) {
                [[[UIAlertView alloc] initWithTitle:@"Login failed" message:jsonObject[KEY_MESSAGE] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            else{
                NSLog(@"Nikolai : Login Successful.");
                
                UINavigationController* parentController = ((UINavigationController*)self.presentingViewController);
                [parentController popToRootViewControllerAnimated:NO];
                [self dismissViewControllerAnimated:NO completion:nil];
                [Session setLoginDataWithData:jsonObject[KEY_DATA]];
                if([jsonObject[KEY_DATA][KEY_USER_GROUP] isEqualToString: USERTYPE_VENDOR])
                    [parentController.topViewController performSegueWithIdentifier:@"loginVendorSegue" sender:self.presentingViewController];
                else
                    [parentController.topViewController performSelectorInBackground:@selector(loadToolbarImage) withObject:nil];

            }
        }
    }];
}
- (IBAction)onSignUpAsUser:(id)sender {
    UINavigationController* parentController = ((UINavigationController*)self.presentingViewController);
    [parentController popToRootViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:NO completion:nil];
    [parentController.topViewController performSegueWithIdentifier:@"signUpSegue" sender:self.presentingViewController];
}
- (IBAction)onSignUpAsVendor:(id)sender {
    UINavigationController* parentController = ((UINavigationController*)self.presentingViewController);
    [parentController popToRootViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:NO completion:nil];
    [parentController.topViewController performSegueWithIdentifier:@"signUpSegue" sender:self.presentingViewController];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed. return NO to ignore.
{
    if(textField == self.txtEmail)
        return [self.txtPassword becomeFirstResponder];
    else
        [self onLogin:nil];
    return [textField resignFirstResponder];
}

-(BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


@end
