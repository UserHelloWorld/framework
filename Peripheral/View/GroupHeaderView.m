//
//  GroupHeaderView.m
//  Peripheral
//
//  Created by apple on 22/12/17.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "GroupHeaderView.h"

@implementation GroupHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.checkBtn.layer.borderWidth = 1;
    self.checkBtn.layer.borderColor = [UIColor redColor].CGColor;
    self.checkBtn.layer.masksToBounds = YES;
    self.checkBtn.layer.cornerRadius = 5;
}

- (IBAction)checkBtnClick:(UIButton *)sender
{
    if (self.delegate) {
        [self.delegate groupHeaderViewDeleteCell:self];
    }
}

@end
