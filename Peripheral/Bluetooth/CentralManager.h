//
//  CentralManager.h
//  Peripheral
//
//  Created by apple on 15/12/17.
//  Copyright © 2017年 apple. All rights reserved.
//
#define CentralInstance [CentralManager shareInstance]

#import <Foundation/Foundation.h>
#import "BleDevice.h"

@interface CentralManager : NSObject

/** 广播中的所有外设 */
@property (nonatomic, retain) NSMutableArray <BleDevice *> *deviceList;

@property (strong, nonatomic) NSMutableArray *logArray;


@property (assign, nonatomic) BOOL showLog;

+ (CentralManager *)shareInstance;

- (int)deviceCountInOfGroup:(int)groupID;

- (NSMutableArray *)allGroupDevice; //!< 所有分好组的外设

- (int)selectedFlag; //!< 是否有选中过设备

- (NSArray *)getDeviceOfGroup:(int)groupID; //

- (NSMutableArray *)getGroupList;

- (int)existGroup; // 判断是否存在组

- (NSArray *)getNoSetGroup; 

- (NSArray *)getGroupCount:(int)group;

@end
