//
//  Session.m
//  HappyChat
//
//  Created by Alex Johnson on 12/06/2016.
//  Copyright © 2016 NikolaiTomov. All rights reserved.
//

#import "Session.h"
#import "AppDelegate.h"

@implementation Session
+ (bool)isLoggedIn {
    return [self loginData]!=nil;
}
+ (void)logout {
    [Session setLoginDataWithData:nil];
}
+ (void) setLoginDataWithData: (NSDictionary*) data {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data1= [NSKeyedArchiver archivedDataWithRootObject:data];
    [defaults setObject:data1 forKey:@"loginData"];
    [defaults synchronize];
}
+ (NSDictionary*) loginData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"loginData"];
    if(data==nil) return nil;
    NSDictionary *arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return arr;
}
+ (void)setSelectedVendor: (NSDictionary*) vendor {
    AppDelegate *gApp = [UIApplication sharedApplication].delegate;
    gApp.selectedVendor = vendor;
}
+ (NSDictionary*)selectedVendor {
    AppDelegate *gApp = [UIApplication sharedApplication].delegate;
    return gApp.selectedVendor;
}
@end
