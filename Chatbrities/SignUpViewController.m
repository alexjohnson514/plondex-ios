//
//  SignUpViewController.m
//  Chatbrities
//
//  Created by Alex Johnson on 17/06/2016.
//  Copyright © 2016 NikolaiTomov. All rights reserved.
//

#import "SignUpViewController.h"
#import "Const.h"
#import "Session.h"

@implementation SignUpViewController
{
    UITextField *activeTextField;
    CGSize keyboardSize;
    NSArray *textFieldArray;
    UIActivityIndicatorView *indicator;
}
- (IBAction)onToggleAgreement:(id)sender {
    self.chkAggreement.selected = !self.chkAggreement.selected;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.frame = self.view.bounds;
    indicator.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    indicator.hidesWhenStopped = YES;
    
    [self.view addSubview:indicator];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    textFieldArray = @[self.txtEmail, self.txtPassword, self.txtPasswordConfirm, self.txtFirstName, self.txtLastName];
}

#pragma mark - NSNotification
- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    keyboardSize = kbSize;
    
    float diff = self.view.frame.size.height - (activeTextField.frame.origin.y + activeTextField.frame.size.height) - keyboardSize.height - 50;
    
    CGRect br = self.view.frame;
    if(diff>0) diff = 0;
    br.origin.y = diff;
    self.view.frame = br;
}

- (void)keyboardWillHide:(NSNotification*)notification {
    CGRect br = self.view.frame;
    br.origin.y = 0;
    self.view.frame = br;
    keyboardSize = CGSizeZero;
}
-(UITextField *)nextTextField:(UITextField *)txtField{
    if (txtField == self.txtEmail)
        return self.txtPassword;
    else if(txtField == self.txtPassword)
        return self.txtPasswordConfirm;
    else if(txtField == self.txtPasswordConfirm)
        return self.txtFirstName;
    else if(txtField == self.txtFirstName)
        return self.txtLastName;
    return nil;
}

#pragma mark - UITextField Delgate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField != self.txtLastName) {
        [[self nextTextField:textField] becomeFirstResponder];
    }
    else{
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    activeTextField = textField;
    if (keyboardSize.height != 0) {
        float diff = self.view.frame.size.height - (activeTextField.frame.origin.y + activeTextField.frame.size.height) - keyboardSize.height - 50;
        if(diff>0) diff = 0;
        [UIView animateWithDuration:0.5 animations:^{
            CGRect br = self.view.frame;
            br.origin.y = diff;
            self.view.frame = br;
            
        }];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    activeTextField = nil;
}
- (IBAction)onSignUp:(id)sender {
    if([self checkValidInput])
    {
        [indicator startAnimating];
        [self.view endEditing:YES];
        NSString *signUpUrl = [[NSString stringWithFormat:@"%@%@/%@/%@/%@/%@/%@?keygen=%@", SERVER_URL, API_SIGNUP, _txtEmail.text,_txtPassword.text, _txtFirstName.text, _txtLastName.text, [Session userType], AUTH_KEYGEN] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        signUpUrl = [signUpUrl stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:signUpUrl]];
        [urlRequest setTimeoutInterval:30];
        [urlRequest setHTTPMethod:@"GET"];
        
        NSLog(@"Nikolai : %s begin.", __FUNCTION__);
        
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError) {
                [indicator stopAnimating];
                [[[UIAlertView alloc] initWithTitle:@"SignUp failed" message:@"Can't connect to server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                NSLog(@"Nikolai : SignUp Failed.");
            }
            else{
                NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if ([jsonObject[KEY_SUCCESS] intValue] != 1) {
                    [indicator stopAnimating];
                    [[[UIAlertView alloc] initWithTitle:@"SignUp failed" message:jsonObject[KEY_MESSAGE] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
                else{
                    NSLog(@"Nikolai : SignUp Successful.");
                    
                    NSString* newid = jsonObject[KEY_DATA];
                    [self postSignUp:newid];
                    //[Session setLoginDataWithData:jsonObject[KEY_DATA]];
                    
                }
            }
        }];

    }
}
- (void)postSignUp:(NSString*) newid {
    NSString *getUserUrl = [[NSString stringWithFormat:@"%@%@/%@?keygen=%@", SERVER_URL, API_GET_USER, newid, AUTH_KEYGEN] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:getUserUrl]];
    [urlRequest setTimeoutInterval:30];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSLog(@"Nikolai : %s begin.", __FUNCTION__);
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [indicator stopAnimating];
        if (connectionError) {
            [[[UIAlertView alloc] initWithTitle:@"Get User failed" message:@"Can't connect to server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            NSLog(@"Nikolai : Get User Failed.");
        }
        else{
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([jsonObject[KEY_SUCCESS] intValue] != 1) {
                [[[UIAlertView alloc] initWithTitle:@"Get User failed" message:jsonObject[KEY_MESSAGE] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            else{
                NSLog(@"Nikolai : Get User Successful.");
                
                UINavigationController* parentController = self.navigationController;
                [parentController popToRootViewControllerAnimated:NO];
                [Session setLoginDataWithData:jsonObject[KEY_DATA]];
                if([[Session userType] isEqualToString:USERTYPE_VENDOR])
                {
                    [parentController.topViewController performSegueWithIdentifier:@"loginVendorSegue" sender:parentController.topViewController];
                } else if([[Session userType] isEqualToString:USERTYPE_USER]){
                    [parentController.topViewController performSelectorInBackground:@selector(loadToolbarImage) withObject:nil];                }
            }
        }
    }];
}
- (IBAction)onFBSignUp:(id)sender {
}



- (BOOL)checkValidInput {
    if(!self.chkAggreement.selected)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Check agreement to sign up." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    for (UITextField *txtField in textFieldArray) {
        if(txtField.text == nil || [txtField.text isEqualToString:@""]){
            
            NSString *message = nil;
            
            if (txtField == self.txtEmail) {
                message = @"Please input email address.";
            }
            else if(txtField == self.txtFirstName){
                message = @"Please input first name.";
            }
            else if(txtField == self.txtLastName){
                message = @"Please input last name.";
            }
            else if(txtField == self.txtPassword){
                message = @"Please input password.";
            }
            else if(txtField == self.txtPasswordConfirm){
                message = @"Please input password again.";
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            return NO;
        }
    }
    
    
    
    if (![self NSStringIsValidEmail:self.txtEmail.text]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Email address isn't correct." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    if (![self.txtPassword.text isEqualToString:self.txtPasswordConfirm.text]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Re-typing password isn't correct." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    
    return YES;
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString {
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}
@end
