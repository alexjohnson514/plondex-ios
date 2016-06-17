//
//  Session.h
//  Chatbrities
//
//  Created by Alex Johnson on 12/06/2016.
//  Copyright © 2016 NikolaiTomov. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSString *userType;
@interface Session : NSObject
+ (bool)isLoggedIn;
+ (void)logout;
+ (void) setLoginDataWithData: (NSDictionary*) data;
+ (NSDictionary*) loginData;
+ (void)setSelectedVendor: (NSDictionary*) vendor;
+ (NSDictionary*)selectedVendor;
+ (void)setSignUpType:(NSString*)type;
+ (NSString*)userType;
@end
