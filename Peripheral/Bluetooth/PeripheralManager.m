//
//  PeripheralManager.m
//  Peripheral
//
//  Created by apple on 15/12/17.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "PeripheralManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface PeripheralManager ()<CBPeripheralManagerDelegate>
{
    float _countTick;
}

@property (strong, nonatomic) CBPeripheralManager *peripheralMgr;
@property (strong, nonatomic) NSMutableArray *advDataArray;

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation PeripheralManager

+ (PeripheralManager *)shareInstance {
    static PeripheralManager *peripheral = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        peripheral = [[PeripheralManager alloc] init];
    });
    return peripheral;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.peripheralMgr = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        self.advDataArray = [NSMutableArray array];
    }
    return self;
}

- (UInt8)getFlag
{
    self.serialNumber ++;
    if (self.serialNumber == 0 || self.serialNumber == 256) {
        self.serialNumber = 1;
    }
    return self.serialNumber;
}

- (void)createTimer {
    [self stopTimer];
    _countTick = 2;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tick) userInfo:nil repeats:YES];
}

- (void)tick {
    if (_countTick == 0)
    {
        [self stopTimer];
        [self.peripheralMgr stopAdvertising];
    }
    _countTick --;
}

- (void)stopTimer {
    if (self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)ble_switch:(BleDevice *)dev Mask:(UInt8)mask
{
    unsigned char buf[16];
    memset(buf, 0x00, 16);
    buf[0] = dev.companySet; // firmware index : 5
    buf[1] = 0x11; // device type
    buf[2] = mask; // group mask
    buf[3] = 0x08;
    
    buf[12] = [self getFlag];
    buf[13] = 0xb5;
    buf[14] = 0x5b;
    buf[15] = 0x00;
    
    for(int i = 0; i < 15; i++)
    {
        buf[15] += buf[i];
    }
    [self sendAdv:buf];
}

- (void)ble_small:(BleDevice *)dev mask:(UInt8)mask
{
    unsigned char buf[16];
    memset(buf, 0x00, 16);
    buf[0] = dev.companySet; // firmware index : 5
    buf[1] = 0x11; // device type
    buf[2] = mask; // group mask
    buf[3] = 0x0b;
    buf[7] = 0x00;
    buf[8] = 0x0a;
    
    buf[12] = [self getFlag];
    buf[13] = 0xb5;
    buf[14] = 0x5b;
    buf[15] = 0x00;
    
    for(int i = 0; i < 15; i++)
    {
        buf[15] += buf[i];
    }
    [self sendAdv:buf];
}

- (void)ble_setRGB:(BleDevice *)dev mask:(UInt8)mask R:(UInt8)R G:(UInt8)G B:(UInt8)B warm:(UInt8)w cold:(UInt8)c {
    unsigned char buf[16];
    memset(buf, 0x00, 16);
    buf[0] = dev.companySet; // firmware index : 5
    buf[1] = 0x11; // device type
    buf[2] = mask; // group mask
    buf[3] = 0x10;
    buf[4] = R;
    buf[5] = G;
    buf[6] = B;
    buf[7] = c;
    buf[8] = w;
    
    buf[12] = [self getFlag];
    buf[13] = 0xb5;
    buf[14] = 0x5b;
    buf[15] = 0x00;
    
    for(int i = 0; i < 15; i++)
    {
        buf[15] += buf[i];
    }
    [self sendAdv:buf];
}

- (void)ble_testA:(UInt8)a B:(UInt8)b {
    unsigned char buf[16];
    memset(buf, 0x00, 16);
    buf[0] = 0xb5;
    buf[1] = 0x5b;
    buf[2] = a;
    buf[3] = b;
    [self sendAdv:buf];
}

- (void)ble_timer:(BleDevice *)dev mask:(UInt8)mask time:(UInt8)time {
    unsigned char buf[16];
    memset(buf, 0x00, 16);
    buf[0] = dev.companySet; // firmware index : 5
    buf[1] = 0x11; // device type
    buf[2] = mask; // group
    buf[3] = 0x0f;
    buf[4] = time & 0xff;
    
    buf[12] = [self getFlag];
    buf[13] = 0xb5;
    buf[14] = 0x5b;
    buf[15] = 0x00;
    
    for(int i = 0; i < 15; i++)
    {
        buf[15] += buf[i];
    }
    [self sendAdv:buf];
}

- (void)ble_switch:(BleDevice *)dev mask:(UInt8)mask onOff:(int)onOff {
    unsigned char buf[16];
    memset(buf, 0x00, 16);
    buf[0] = dev.companySet; // firmware index : 5
    buf[1] = 0x11; // device type
    buf[2] = mask; // group
    buf[3] = 0x02;
    buf[4] = onOff & 0xff;
    
    buf[12] = [self getFlag];
    buf[13] = 0xb5;
    buf[14] = 0x5b;
    buf[15] = 0x00;
    
    for(int i = 0; i < 15; i++)
    {
        buf[15] += buf[i];
    }
    [self sendAdv:buf];
}

- (void)ble_disbandGroup:(BleDevice *)dev {
    unsigned char buf[16];
    memset(buf, 0x00, 16);
    buf[0] = dev.companySet; // firmware index : 5
    buf[1] = 0x11; // device type
    buf[2] = 0x01 << (dev.groupID -1); // group
    buf[3] = 0x0e;
    buf[12] = [self getFlag];
    buf[13] = 0xb5;
    buf[14] = 0x5b;
    buf[15] = 0x00;
    
    for(int i = 0; i < 15; i++)
    {
        buf[15] += buf[i];
    }
    [self sendAdv:buf];

}
- (void)ble_setGroup:(BleDevice *)ble group:(int)groupID
{
    if(groupID > 8)
    {
        groupID = 1;
    }
    unsigned char buf[16];
    memset(buf, 0x00, 16);
    buf[0] = ble.companySet; // firmware index : 5
    buf[1] = 0x11; // device type
    if (ble.groupID == 0) {
        buf[2] = 0x00;
    } else {
        buf[2] = 0x01 << (ble.groupID -1); // group
    }
    buf[3] = 0x0d;
    buf[4] = (ble.address >> 16) & 0xff;
    buf[5] = (ble.address >> 8) & 0xff;
    buf[6] = (ble.address >> 0) & 0xff;
    buf[7] = groupID & 0xff;
    
    buf[12] = [self getFlag];
    buf[13] = 0xb5;
    buf[14] = 0x5b;
    buf[15] = 0x00;
    
    for(int i = 0; i < 15; i++)
    {
        buf[15] += buf[i];
    }
    
    [self sendAdv:buf];
}

- (void)sendAdv:(unsigned char *)buf
{
    NSString *struuid = @"";
    for(int i = 15; i >= 0; i--)
    {
        struuid = [struuid stringByAppendingFormat:@"%02X", buf[i]];
        if(i == 12 || i == 10 || i == 8 || i == 6) struuid = [struuid stringByAppendingString:@"-"];
    }
    NSString *strname = @"11111";
    
    NSDictionary *advdata = @{CBAdvertisementDataLocalNameKey : strname, CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:struuid]]};
    
    NSLog(@"advdata = %@",advdata);
    
    if (self.peripheralMgr.isAdvertising) {
        [self.peripheralMgr stopAdvertising];
    }
    
    [self createTimer];

    [self.peripheralMgr startAdvertising:advdata];
}


- (void)startAdvData
{
    if (self.advDataArray.count < 1)      return;
    
    if (self.peripheralMgr.isAdvertising) return;
    
    [self createTimer];

    NSDictionary *advData = [self.advDataArray firstObject];
    
    [self.peripheralMgr startAdvertising:advData];
    
    [self.advDataArray removeObjectAtIndex:0];
}

/*
-(void)sendMsg2DeviceMax20bytes:(NSData *)data
{
//    return;
    if (data.length < 1 || data == nil) {
        return;
    }
    NSMutableData *mData = [NSMutableData data];
    UInt8 head[3];
    head[0]  = 0xb5;
    head[1]  = 0x5b;
    head[2] |= 0x40;
    head[2] |= [self getFlag];
    // 包头
    [mData appendBytes:head length:3];
    [mData appendData:data];
    
    if (mData.length != 20) {
        int count = 20 - (int)mData.length;
        NSMutableData *fillData = [NSMutableData data];
        UInt8 nByte = 0x00;
        for (int i = 0; i < count; i++) {
            [fillData appendBytes:&nByte length:1];
        }
        [mData appendData:fillData];
    }
    
    NSLog(@"%@",mData);
    UInt8 *buf = (UInt8 *)mData.bytes;
    
    //    buf[0] = 0xb5;
    //    buf[1] = 0x5b;
    // 第三个字节的高2bit表示数据来源，
    // 00 : - 未知
    // 01 : - ios
    // 10 : - android
    // 11 : - 遥控器
    
//    buf[2] |= 0x40;
//    buf[2] &= 0x40;
    NSString *struuid = @"";
    for(int i = 15; i >= 0; i--)
    {
        struuid = [struuid stringByAppendingFormat:@"%02X", buf[i]];
        if(i == 12 || i == 10 || i == 8 || i == 6) struuid = [struuid stringByAppendingString:@"-"];
    }
    NSString *strname = @"";
    for(int i = 16; i < 20; i++)
    {
        strname = [strname stringByAppendingFormat:@"%02X", buf[i]];
    }
    
    NSDictionary *advdata = @{CBAdvertisementDataLocalNameKey : strname, CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:struuid]]};
    
    if (self.peripheralMgr.isAdvertising) {
        [self.peripheralMgr stopAdvertising];
    }
    [self.peripheralMgr startAdvertising:advdata];

}
*/
#pragma mark = CBPeripheralManagerDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state == CBCentralManagerStatePoweredOn) {
        
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"%s %d",__func__,__LINE__);
    
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"%s %d",__func__,__LINE__);

}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    NSLog(@"%s %d",__func__,__LINE__);

}

@end
