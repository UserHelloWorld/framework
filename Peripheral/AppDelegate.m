//
//  AppDelegate.m
//  Peripheral
//
//  Created by apple on 13/12/17.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    UInt8 c = 0xff;
//    UInt8 d = 0xbb;
//    UInt16 f = c;
//    f = f << 8 | d;
    
//    UInt8 a = 0xff;
//    UInt8 b = 0xbb;
//    UInt8 dd[2];
//    dd[0] = a;
//    dd[1] = b;
//
//    UInt8 a1 = 0xff;
//    UInt8 b2 = 0xbb;
//    UInt8 dddd[2];
//    dddd[0] = a1;
//    dddd[1] = b2;
//
//    NSData *da = [NSData dataWithBytes:dd length:2];
//    NSData *cc = [NSData dataWithBytes:dddd length:2];
//    if ([da isEqual:cc]) {
//        NSLog(@"dddd");
//    }
    
//    BleDevice *d = [[BleDevice alloc] init];
//    d.groupID = 2;
//    d.address = 123;
//    NSMutableArray *arr = [NSMutableArray array];
//    [arr addObject:d];
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    [dict setObject:arr forKey:@"1"];
//    NSLog(@"%@",dict);
//
//   NSArray *a = [dict objectForKey:@"1"];
//    NSLog(@"%@",a);
//   0000 1100
    
    return YES;
}

- (void)test {
    NSArray *aa = [NSArray arrayWithObjects:@"3",@"2",@"1",@"4", nil];
    NSArray *array2 = [aa sortedArrayUsingSelector:@selector(compare:)];
    NSLog(@"%@",array2);

   NSArray *gg = [aa sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
