//
//  BoundHeaderView.h
//  Peripheral
//
//  Created by apple on 25/12/17.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BoundHeaderView;

@protocol BoundHeaderViewDelegate <NSObject>

@optional

- (void)boundHeaderViewDidSelected:(BoundHeaderView *)header;

@end

/**
  绑定头部Header
 */
@interface BoundHeaderView : UITableViewHeaderFooterView

@property (copy, nonatomic) id <BoundHeaderViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;

@end
