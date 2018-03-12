
//
//  Master.m
//  Peripheral
//
//  Created by apple on 29/12/17.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "Master.h"

@implementation Master

+ (Master *)instance {
    static Master *master = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        master = [[Master alloc] init];
    });
    return master;
}
- (NSMutableArray *)groupNameArray {
    if (!_groupNameArray) {
        _groupNameArray = [NSMutableArray array];
        for (int i = 0; i< 8; i++) {
            _groupNameArray = [NSMutableArray array];
        }
    }
    return _groupNameArray;
}
@end
