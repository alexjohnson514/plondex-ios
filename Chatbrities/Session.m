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
    AppDelegate *gApp = [UIApplication sharedApplication].delegate;
    gApp.loginData = data;
}
+ (NSDictionary*) loginData {
    AppDelegate *gApp = [UIApplication sharedApplication].delegate;
    return gApp.loginData;
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
