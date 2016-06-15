//
//  ChatViewController.h
//  HappyChat
//
//  Created by Alex Johnson on 12/06/2016.
//  Copyright © 2016 NikolaiTomov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SKYLINK/SKYLINK.h>

@interface ChatViewController : UIViewController<SKYLINKConnectionMediaDelegate, SKYLINKConnectionLifeCycleDelegate, SKYLINKConnectionRemotePeerDelegate>

@end
