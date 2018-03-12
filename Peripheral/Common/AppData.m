//
//  AppData.m
//  Peripheral
//
//  Created by apple on 29/12/17.
//  Copyright © 2017年 apple. All rights reserved.
//

#define GroupName @"GroupName"
#define Timer     @"timer"

#import "AppData.h"

@implementation AppData

+ (NSArray *)getGroupNameArray {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    return [user objectForKey:GroupName];
}
+ (void)saveGroupNameArray:(NSArray *)array
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:array forKey:GroupName];
    [user synchronize];
}

+ (void)saveTimer:(int)time {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setInteger:time forKey:Timer];
    [user synchronize];
}
+ (int)getTimer {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    return (int)[user integerForKey:Timer];
}

@end
