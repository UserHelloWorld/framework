//
//  PaletteView.h
//  LEDColor
//
//  Created by apple on 2017/10/21.
//  Copyright © 2017年 chenxin · luo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PaletteView;

@protocol PaletteViewDelegate <NSObject>

@optional

-(void)palette:(PaletteView *)patetteView choiceColor:(UIColor *)color;

@end


/**
 调色板类
 */
@interface PaletteView : UIView

@property (nonatomic,weak) id<PaletteViewDelegate> delegate;

@property (nonatomic,assign) CGPoint sliderCenter;

@end
