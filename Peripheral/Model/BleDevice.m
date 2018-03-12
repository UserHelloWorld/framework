//
//  BleDevice.m
//  Peripheral
//
//  Created by apple on 18/12/17.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "BleDevice.h"

@implementation BleDevice

+ (BleDevice *)deviceFromData:(unsigned char *)buf
{
    BleDevice *device = [[BleDevice alloc] init];
    [device setCompanySet:buf[0]];
    [device setDeviceSet:buf[1]];
    [device setGroupID:buf[2]];
    [device setAddress:((buf[3] << 16) | (buf[4] << 8) | buf[5])];
    [device setPowerState:buf[7]];
    [device setMode:buf[8]];
    [device setCountDownTime:buf[9]];
    [device setTimer:buf[10]];
  
    [device setWarm:buf[13]];
    [device setCold:buf[14]];
    return device;
}

- (BOOL)isEqual2:(BleDevice *)dev
{
    
    if (self.companySet == dev.companySet && self.address == dev.address) {
        return YES;
    }
    return NO;
}

- (BOOL)isChange:(BleDevice *)dev
{
    if (self.newGroupID != self.groupID)
    {
        return YES;
    }
    return NO;
}

- (BOOL)hasChanged:(BleDevice *)dev
{
    if(self.companySet == dev.companySet &&
       self.address == dev.address &&
       self.groupID == dev.groupID &&
       self.powerState == dev.powerState &&
       self.mode == dev.mode &&
       self.countDownTime == dev.countDownTime &&
       self.timer == dev.timer &&
       self.warm == dev.warm &&
       self.cold == dev.cold)
    {
        return NO;
    }
    return YES;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"companySet=%d deviceSet=%d groupId=%d address=%d newGroup=%d powerstate=%d",_companySet,_deviceSet,_groupID,_address,_newGroupID,_powerState];
}
@end
