//
//  BleDevice.h
//  Peripheral
//
//  Created by apple on 18/12/17.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BleDevice : NSObject

@property (assign, nonatomic) int selectFlag;

@property (nonatomic, assign) int companySet;
@property (nonatomic, assign) int deviceSet;
@property (assign, nonatomic) int groupID;
@property (assign, nonatomic) int address;
@property (assign, nonatomic) int powerState;
@property (assign, nonatomic) int mode;
@property (assign, nonatomic) int countDownTime;

@property (assign, nonatomic) int timer;


@property (assign, nonatomic) int warm;
@property (assign, nonatomic) int cold;

@property (assign, nonatomic) BOOL signSend;

@property (assign, nonatomic) int newGroupID;

@property (strong, nonatomic) NSDate *foundDate;

- (BOOL)isEqual2:(BleDevice *)dev;

- (BOOL)isChange:(BleDevice *)dev;

- (BOOL)hasChanged:(BleDevice *)dev;

+ (BleDevice *)deviceFromData:(unsigned char *)buf;

@end
