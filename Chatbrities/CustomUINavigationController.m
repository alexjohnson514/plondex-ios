//
//  CustomUINavigationController.m
//  Chatbrities
//
//  Created by Alex Johnson on 15/06/2016.
//  Copyright © 2016 NikolaiTomov. All rights reserved.
//

#import "CustomUINavigationController.h"

@implementation CustomUINavigationController

-(BOOL)shouldAutorotate
{
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
@end
