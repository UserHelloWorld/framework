//
//  GroupCell.h
//  Peripheral
//
//  Created by apple on 15/12/17.
//  Copyright © 2017年 apple. All rights reserved.
//



#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, cellType) {
    cellTypeTop,
    cellTypeMiddle,
    cellTypeBottom,
    cellTypeOnlyOne
};

@protocol GroupCellDelegate <NSObject>

@end

@interface GroupCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (nonatomic, assign) cellType cellBorderType;

@end
