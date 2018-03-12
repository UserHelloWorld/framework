//
//  HintView.m
//  Peripheral
//
//  Created by apple on 05/01/18.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "HintView.h"

@implementation HintView

+ (HintView *)hintViewInstance {
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil][0];
}
- (void)startAnimating {
    [self.activityView startAnimating];
}
- (void)stopAnimating {
    [self.activityView stopAnimating];
}
- (void)showTitle:(NSString *)title{
    self.hidden = NO;
    self.titleLabel.text = title;
    [self startAnimating];
}
- (void)hide {
    
    self.hidden = YES;
    [self stopAnimating];
}
@end
