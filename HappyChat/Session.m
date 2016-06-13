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
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedIn"];
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
@end
