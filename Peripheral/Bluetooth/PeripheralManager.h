//
//  PeripheralManager.h
//  Peripheral
//
//  Created by apple on 15/12/17.
//  Copyright © 2017年 apple. All rights reserved.
//
#define PeripheralInstance [PeripheralManager shareInstance]

#import <Foundation/Foundation.h>

@interface PeripheralManager : NSObject

@property (assign, nonatomic) int serialNumber; //!< 序列号

- (void)ble_testA:(UInt8)a B:(UInt8)b;

+ (PeripheralManager *)shareInstance;

- (void)ble_setGroup:(BleDevice *)ble group:(int)groupID;

- (void)ble_disbandGroup:(BleDevice *)dev;

- (void)ble_switch:(BleDevice *)dev mask:(UInt8)mask onOff:(int)onOff;

- (void)ble_switch:(BleDevice *)dev Mask:(UInt8)mask;

- (void)ble_timer:(BleDevice *)dev mask:(UInt8)mask time:(UInt8)time;

- (void)ble_setRGB:(BleDevice *)dev mask:(UInt8)mask R:(UInt8)R G:(UInt8)G B:(UInt8)B warm:(UInt8)w cold:(UInt8)c;

- (void)ble_small:(BleDevice *)dev mask:(UInt8)mask;


@end
