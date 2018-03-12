//
//  PaletteView.m
//  LEDColor
//
//  Created by apple on 2017/10/21.
//  Copyright © 2017年 chenxin · luo. All rights reserved.
//
#define pi 3.14159265358979323846


#define radiansToDegrees(x) (180.0 * x / pi)

#define SliderWidth 20

#import "PaletteView.h"
#import "HSVWithNew.h"

@interface PaletteView ()
{
    HSVType currentHSVWithNew;
}
@property (nonatomic,strong)UIImageView *paletteImageView;
@property (strong, nonatomic) dispatch_queue_t queue;

@property (nonatomic,strong)UIImageView *sliderImageView;

@end

@implementation PaletteView


#pragma mark 初始化
-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self createUI];
        self.queue = dispatch_queue_create(NULL, DISPATCH_CURRENT_QUEUE_LABEL);

    }
    return self;
}
-(void)setSliderCenter:(CGPoint)sliderCenter{
    _sliderCenter=sliderCenter;
    self.sliderImageView.center=sliderCenter;
    
}
#pragma mark 添加UI
-(void)createUI
{
    UIImage *sliderImg = [UIImage imageNamed:@"followCircle"];
    
    sliderImg = [self customImageWith:sliderImg toSize:sliderImg.size];
    
    self.sliderImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SliderWidth, SliderWidth)];
    
    self.sliderImageView.image = sliderImg;
    
    self.paletteImageView = [[UIImageView alloc]initWithFrame:CGRectMake(SliderWidth/2, SliderWidth/2, self.frame.size.width-SliderWidth+0.1, self.frame.size.height-SliderWidth+0.1)];
    
    UIImage *paletteImg = [UIImage imageNamed:@"paletteColor"];
    
    paletteImg = [self customImageWith:paletteImg toSize:paletteImg.size];
    
    self.paletteImageView.image = paletteImg;
    
    [self addSubview:self.paletteImageView];
    
    [self addSubview:self.sliderImageView];
    
    self.sliderImageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}



#pragma mark - 触摸事件
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self calculateShowColor:touches];
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self calculateShowColor:touches];
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self calculateShowColor:touches];
}

#pragma mark - 计算颜色
-(void)calculateShowColor:(NSSet<UITouch *> *)touches
{
    UITouch *touchObj=touches.anyObject;
    CGPoint movePoint=[touchObj locationInView:self];                       // 得到滑动的点
    
    UIColor *color=[self calculateCenterPointInView:movePoint];            //  计算得到真正的中心点和颜色
    if([self.delegate respondsToSelector:@selector(palette:choiceColor:)]){
        [self.delegate palette:self choiceColor:color];
    }
    
}

#pragma mark 计算中心点位置和获取颜色
-(UIColor *)calculateCenterPointInView:(CGPoint)point{
    
    CGPoint center=CGPointMake(self.frame.size.width/2,self.frame.size.height/2);  // 中心点
    double radius=self.frame.size.width/2;          // 半径
    double dx=ABS(point.x-center.x);    //  ABS函数: int类型 取绝对值
    double dy=ABS(point.y-center.y);   //   atan pow sqrt也是对应的数学函数
    double angle=atan(dy/dx);
    if (isnan(angle)) angle=0.0;
    double dist=sqrt(pow(dx,2)+pow(dy,2));
    
    double saturation=MIN(dist/radius,1.0);
    
    if (dist<10) saturation=0;
    if (point.x<center.x) angle=M_PI-angle;
    if (point.y>center.y) angle=2.0*M_PI-angle;
    
    double ff = 180/M_PI * angle;
    NSLog(@"d: %f, angle %f - %f", dist, angle, ff);
    HSVType currentHSV=HSVTypeMake(angle/(2.0*M_PI), saturation, 1.0);
    
   CGPoint colorPoint = [self centerPointValue:currentHSV];    // 计算中心点位置
    
    UIColor *color= [self colorOfPoint:colorPoint];
    
//    unsigned r, g, b;

    return color;
}

#pragma mark 真正显示颜色的中心点
-(CGPoint)centerPointValue:(HSVType)currentHSV{
    
    currentHSVWithNew=currentHSV;
    currentHSVWithNew.v=1.0;
    double angle=currentHSVWithNew.h*2.0*M_PI;
    CGPoint center=CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    double radius=self.frame.size.width/2-self.sliderImageView.frame.size.width/2;
    radius *=currentHSVWithNew.s;
    
    CGFloat x=center.x+cosf(angle)*radius;
    CGFloat y=center.y-sinf(angle)*radius;
    
    x=roundf(x-self.sliderImageView.frame.size.width/2)+self.sliderImageView.frame.size.width/2;
    y=roundf(y-self.sliderImageView.frame.size.height/2)+self.sliderImageView.frame.size.height/2;
    
    self.sliderImageView.center=CGPointMake(x,y);
    
    CGPoint colorPoint = CGPointMake(x, y);
    return colorPoint;
}
// 根据点计算颜色
- (UIColor *)colorOfPoint:(CGPoint)point {
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    
    return color;
}

- (UIImage *)customImageWith:(UIImage *)image toSize:(CGSize)toSize
{
    UIGraphicsBeginImageContext(CGSizeMake(toSize.width, toSize.height));
    [image drawInRect:CGRectMake(0, 0, toSize.width, toSize.height)];
    UIImage *customImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return customImage;
}

@end
