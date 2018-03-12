//
//  GroupCell.m
//  Peripheral
//
//  Created by apple on 15/12/17.
//  Copyright © 2017年 apple. All rights reserved.
// https://www.jianshu.com/p/31c950e721b1

#import "GroupCell.h"

@interface GroupCell ()

@end

@implementation GroupCell

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    UIColor *color = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [color set];
    switch (self.cellBorderType) {
        case cellTypeTop:
        {
            UIBezierPath* aPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height+1) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
            
            aPath.lineWidth = 1;
            [aPath stroke];
            
            UIBezierPath *maskPath =[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
            CAShapeLayer *masklayer = [[CAShapeLayer alloc] init];
            masklayer.path = maskPath.CGPath;
            masklayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) ;
            self.layer.mask = masklayer;
        }
            break;
            case cellTypeMiddle:
        {
            UIBezierPath* aPath = [UIBezierPath bezierPath];
            [aPath moveToPoint:CGPointMake(0, 0)];
            [aPath addLineToPoint:CGPointMake(0, self.bounds.size.height)];
            [aPath moveToPoint:CGPointMake(self.bounds.size.width, 0)];
            [aPath addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height)];
            aPath.lineWidth = 1;
            [aPath stroke];
        }
            break;
            case cellTypeBottom:
        {
            UIBezierPath* aPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, -1, self.bounds.size.width, self.bounds.size.height+1) byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
            
            aPath.lineWidth = 1;
            [aPath stroke];
            
            UIBezierPath *maskPath =[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
            CAShapeLayer *masklayer = [[CAShapeLayer alloc] init];
            masklayer.path = maskPath.CGPath;
            masklayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) ;
            self.layer.mask = masklayer;
        }
            break;
            case cellTypeOnlyOne:
        {
            UIBezierPath* aPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
            
            aPath.lineWidth = 1;
            [aPath stroke];
            
            UIBezierPath *maskPath =[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) byRoundingCorners:UIRectCornerAllCorners  cornerRadii:CGSizeMake(10, 10)];
            
            CAShapeLayer *masklayer = [[CAShapeLayer alloc] init];
            masklayer.path = maskPath.CGPath;
            masklayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) ;
            self.layer.mask = masklayer;
        }
            break;
        default:
            break;
    }
}
- (void)setCellBorderType:(cellType)cellBorderType {
    _cellBorderType = cellBorderType;
    [self setNeedsDisplay];
}

- (IBAction)checkBtnClick:(UIButton *)sender{}

@end
