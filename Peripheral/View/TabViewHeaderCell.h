//
//  TabViewHeaderCell.h
//  Peripheral
//
//  Created by apple on 25/12/17.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabViewHeaderCell : UITableViewHeaderFooterView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *rightLabel;

@property (weak, nonatomic) IBOutlet UIImageView *headerImgView;

@end
