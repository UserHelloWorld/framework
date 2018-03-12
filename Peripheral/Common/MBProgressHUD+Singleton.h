//
//  MBProgressHUD+Sington.h
//  AirCleaner
//
//  Created by Shaojun Han on 10/23/15.
//  Copyright © 2015 HadLinks. All rights reserved.
//

#import "MBProgressHUD.h"

#define HUDInstance [MBProgressHUD sharedInstance]

@interface MBProgressHUD (Singleton)

// 单例
+ (instancetype)fexibleInstance;
+ (instancetype)sharedInstance;
- (void)hide;
- (void)showWithTitle:(NSString *)title dimable:(BOOL)dimable;
+ (void)showWithTitle:(NSString *)title dimable:(BOOL)dimable delay:(NSTimeInterval)delay;
+ (void)toastWithMessage:(NSString *)message;
+ (void)centerShowMessage:(NSString *)message;
@end
