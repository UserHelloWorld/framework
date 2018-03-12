//
//  HintView.h
//  Peripheral
//
//  Created by apple on 05/01/18.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HintView : UIView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

+ (HintView *)hintViewInstance;
- (void)showTitle:(NSString *)title;
- (void)hide;
@end
