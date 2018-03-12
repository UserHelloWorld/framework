//
//  CentralManager.m
//  Peripheral
//
//  Created by apple on 15/12/17.
//  Copyright © 2017年 apple. All rights reserved.
//

#define Light   0x24

#define ManufacturerData @"kCBAdvDataManufacturerData"

#import "CentralManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BleDevice.h"

@interface CentralManager ()<CBCentralManagerDelegate>

@property (strong, nonatomic) CBCentralManager *centralMgr;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) dispatch_queue_t queue;


@end

@implementation CentralManager

+ (CentralManager *)shareInstance {
    static CentralManager *central = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        central = [[CentralManager alloc] init];
    });
    return central;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.centralMgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.deviceList = [NSMutableArray array];
        self.logArray = [NSMutableArray array];
        self.queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}


- (void)startScan {
    [self.centralMgr scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    [self createTime];
}

- (void)stopScan {
    [self.centralMgr stopScan];
}
#pragma mark = CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self startScan];
    } else {
        [self stopScan];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    if (RSSI.integerValue > -15)  return;
    if (RSSI.integerValue < -100) return;
    
    NSData *data = [advertisementData objectForKey:ManufacturerData];
    
    if(data.length >= 16)
    {
        NSLog(@"%@",advertisementData);
        unsigned char *buf = (unsigned char *)data.bytes;
                
        unsigned char cksum = 0x00;
        for(int i = 0; i < 15; i++)
        {
            cksum += buf[i];
        }
        if(cksum == buf[15])
        {
            [self processAdvCommand:buf];

            dispatch_async(self.queue, ^{
                NSLog(@"currentThread = %@",[NSThread currentThread]);
                if (self.showLog) {
                    if (self.logArray.count > 22) {
                        [self.logArray removeObjectAtIndex:0];
                    }
                    [self.logArray addObject:[NSDate date]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        PostNotification(@"dataArray", self.logArray);
                    });
                }
            });
         
        }
    }
    
}

- (void)processAdvCommand:(unsigned char *)buf
{
    if (buf[1] != Light) return;
    if (buf[2] > 8) return;
    NSLog(@"                       收到了数据                            ");

    BleDevice *dev = [BleDevice deviceFromData:buf];
    dev.foundDate = [NSDate date];
    int index = [self hasDevice:dev];
    if(index == -1)
    {
        [self.deviceList addObject:dev];

        PostNotification(msgDeviceArrival, dev);
    }
    else
    {
        BleDevice *d = [self.deviceList objectAtIndex:index];
        d.foundDate = [NSDate date];
        if([dev hasChanged:d])
        {
            [self.deviceList replaceObjectAtIndex:index withObject:dev];

            PostNotification(msgDeviceUpdated, dev);
        }
    }
}

- (int)hasDevice:(BleDevice *)ble
{
    for(int i = 0; i < self.deviceList.count; i++)
    {
        BleDevice *d = [self.deviceList objectAtIndex:i];
        
        if([d isEqual2:ble])
        {
            return i;
        }
    }
    return  -1;
}

- (int)deviceCountInOfGroup:(int)groupID
{
    int count = 0;
    for(BleDevice *dev in self.deviceList)
    {
        if (dev.deviceSet != Light) {
            continue;
        }
        if(dev.groupID == groupID) count++;
    }
    return count;
}

- (NSMutableArray *)allGroupDevice
{
    NSArray *arr = [self getGroupList];
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < arr.count; i++) {
        int group = [arr[i] intValue];
        NSArray *groupArr = [self getDeviceOfGroup:group];
        if (groupArr.count > 0) {
            [array addObject:groupArr];
        }
    }
    return array;
}

- (NSArray *)getNoSetGroup
{
    NSMutableArray *array = [NSMutableArray array];
    for (BleDevice *dev in self.deviceList) {
        if (dev.groupID == 0) {
            [array addObject:dev];
        }
    }
    return array;
}

- (NSArray *)getGroupCount:(int)group{
    NSMutableArray *array = [NSMutableArray array];
    for (BleDevice *dev in self.deviceList) {
        if (dev.groupID == group) {
            [array addObject:dev];
        }
    }
    return array;
}

- (NSArray *)getDeviceOfGroup:(int)groupID {
    NSMutableArray *array = [NSMutableArray array];
    for (BleDevice *dev in self.deviceList) {
        if (dev.groupID == groupID && dev.deviceSet == Light) {
            [array addObject:dev];
        }
    }
    return array;
}



- (int)selectedFlag
{
    int count = 0;
    for (BleDevice *dev in self.deviceList)
    {
        if (dev.selectFlag == 1)
        {
            count ++;
        }
    }
    return count;
}

- (int)existGroup {
    for (BleDevice *dev in self.deviceList) {
        if (dev.groupID > 0) {
            return 1;
        }
    }
    return 0;
}

- (NSMutableArray *)getGroupList
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for(BleDevice *dev in self.deviceList)
    {
        if (dev.deviceSet != Light) {
            continue;
        }
        BOOL isExist = NO;
        for(NSNumber *n in array)
        {
            NSNumber *ns = [NSNumber numberWithInt:dev.groupID];
            if(n.intValue == ns.intValue)
            {
                isExist = YES;
                break;
            }
        }
        if(!isExist)
        {
            [array addObject:[NSNumber numberWithInt:dev.groupID]];
        }
    }
//    NSLog(@"多少组的数据===%@",array);
    NSArray *array1 = [array sortedArrayUsingSelector:@selector(compare:)];
//    NSLog(@"排好序的数据===%@",array1);
    NSMutableArray *array2 = [NSMutableArray array];
    [array2 addObjectsFromArray:array1];
    
    for (int i = 0; i< array2.count; i++) {
        if ([array2[i] intValue] == 0) {
            [array2 removeObjectAtIndex:0];
            [array2 addObject:@(0)];
            break;
        }
    }
    return array2;
}


#pragma mark 定时器
- (void)createTime
{
    [self removeTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
}
- (void)tick
{
//    NSLog(@"%s %d",__func__,__LINE__);
    dispatch_async(self.queue, ^{
        NSDate *dateNow = [NSDate date];
        [self.deviceList enumerateObjectsUsingBlock:^(BleDevice *obj, NSUInteger idx, BOOL *stop) {
            if ([dateNow timeIntervalSinceDate:obj.foundDate] > 10) {
                *stop = YES;
                [self.deviceList removeObject:obj];
                dispatch_async(dispatch_get_main_queue(), ^{
                    PostNotification(msgDeviceUpdated, self.deviceList);
                });
            }
        }];
    });
}

- (void)removeTimer
{
    if (self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}
@end
