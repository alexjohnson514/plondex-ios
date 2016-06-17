//
//  VendorTableViewCell.m
//  Chatbrities
//
//  Created by Alex Johnson on 8/06/2016.
//  Copyright (c) 2016 NikolaiTomov. All rights reserved.
//

#import "VendorTableViewCell.h"
#import "Const.h"

@implementation VendorTableViewCell
- (void)layoutSubviews {
    // Initialization code
    CGRect bounds = CGRectMake(self.bounds.origin.x, self.containerView.bounds.origin.y, self.bounds.size.width, self.containerView.bounds.size.height);
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:bounds];
    self.containerView.layer.masksToBounds = NO;
    self.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.containerView.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.containerView.layer.shadowOpacity = 0.5f;
    self.containerView.layer.shadowPath = shadowPath.CGPath;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
