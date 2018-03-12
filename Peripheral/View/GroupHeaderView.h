//
//  GroupHeaderView.h
//  Peripheral
//
//  Created by apple on 22/12/17.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupHeaderView;

@protocol GroupHeaderViewDelegate <NSObject>

- (void)groupHeaderViewDeleteCell:(GroupHeaderView *)headCell;

@end

@interface GroupHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) id <GroupHeaderViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *checkBtn;

@end
