//
//  BoundHeaderView.m
//  Peripheral
//
//  Created by apple on 25/12/17.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "BoundHeaderView.h"

@implementation BoundHeaderView

- (IBAction)btnClick:(id)sender {
    self.checkBtn.selected = !self.checkBtn.selected;
    if ([self.delegate respondsToSelector:@selector(boundHeaderViewDidSelected:)]) {
        [self.delegate boundHeaderViewDidSelected:self];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

@end
