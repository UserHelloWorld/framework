//
//  MBProgressHUD+Sington.m
//  AirCleaner
//
//  Created by Shaojun Han on 10/23/15.
//  Copyright © 2015 HadLinks. All rights reserved.
//

#import "MBProgressHUD+Singleton.h"

@implementation MBProgressHUD (Singleton)

+ (instancetype)fexibleInstance {
    static MBProgressHUD *fexible = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fexible = [[MBProgressHUD alloc] init];
    });
    return fexible;
}

// 单例
+ (instancetype)sharedInstance {
    static MBProgressHUD *hud = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hud = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
        [[self keyWindow] addSubview:hud];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.yOffset = 0;
    });
    return hud;
}

+ (instancetype)toastInstance {
    static MBProgressHUD *toastHud = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        toastHud = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
        [[self keyWindow] addSubview:toastHud];
        toastHud.clipsToBounds = YES;
        toastHud.mode = MBProgressHUDModeText;
        toastHud.yOffset = 10;
        toastHud.dimBackground = NO;
    });
    return toastHud;
}

+ (UIWindow *)keyWindow {
    return [UIApplication sharedApplication].keyWindow;
}

- (void)hide {
    MBProgressHUD *hud = HUDInstance;
    [hud hide:YES];
}
- (void)showWithTitle:(NSString *)title dimable:(BOOL)dimable {
    MBProgressHUD *hud = HUDInstance;
    hud.labelText = title;
    hud.dimBackground = dimable;
    [hud show:YES];
    [hud.superview bringSubviewToFront:hud];
}
+ (void)showWithTitle:(NSString *)title dimable:(BOOL)dimable delay:(NSTimeInterval)delay {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.yOffset = 0;
    
    hud.labelText = title;
    hud.dimBackground = dimable;
    [hud show:YES];
    [hud hide:YES afterDelay:delay];
    [[self keyWindow] addSubview:hud];
    [hud.superview bringSubviewToFront:hud];
}
+ (void)toastWithMessage:(NSString *)message{
    MBProgressHUD *hud = [MBProgressHUD toastInstance];
    hud.labelText = message;
    hud.yOffset = 90;
    [hud show:YES];
    [hud hide:YES afterDelay:0.75];
    [hud.superview bringSubviewToFront:hud];
}

+ (void)centerShowMessage:(NSString *)message
{
    MBProgressHUD *hud = [MBProgressHUD toastInstance];
    hud.labelText = message;
    hud.yOffset = 0;
    [hud show:YES];
    [hud hide:YES afterDelay:0.75];
    [hud.superview bringSubviewToFront:hud];
}

@end
