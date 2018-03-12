//
//  AppData.h
//  Peripheral
//
//  Created by apple on 29/12/17.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppData : NSObject

+ (NSArray *)getGroupNameArray;

+ (void)saveGroupNameArray:(NSArray *)array;

+ (void)saveTimer:(int)time;
+ (int)getTimer;

@end
