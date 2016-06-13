//
//  AppDelegate.h
//  HappyChat
//
//  Created by Alex Johnson on 8/06/2016.
//  Copyright (c) 2016 NikolaiTomov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SKYLINK/SKYLINK.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSDictionary* loginData;
@property (strong, nonatomic) NSDictionary* selectedVendor;
@property (strong, nonatomic) SKYLINKConnection* skylinkConnection;
@end

