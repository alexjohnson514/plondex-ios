//
//  VendorTableViewCell.h
//  HappyChat
//
//  Created by Alex Johnson on 8/06/2016.
//  Copyright (c) 2016 NikolaiTomov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VendorTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *vendorPhoto;
@property (weak, nonatomic) IBOutlet UILabel *vendorName;
@property (weak, nonatomic) IBOutlet UILabel *vendorCost;

@end