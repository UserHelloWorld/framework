//
//  MainViewController.m
//  Peripheral
//
//  Created by apple on 15/12/17.
//  Copyright © 2017年 apple. All rights reserved.
//
#define Leading 15

#import "MainViewController.h"
#import "CentralManager.h"
#import "PeripheralManager.h"
#import "ViewControllerGroup.h"
#import "SelectedGroupController.h"
#import "PaletteView.h"
#import "CXSlider.h"
#import "AppData.h"
#import "UpdateApp.h"
#import "RSSICell.h"

@interface MainViewController ()<PaletteViewDelegate,CXSliderDelegate,UITableViewDelegate,UITableViewDataSource>
{
    CGFloat _light;
    UInt8 _R;
    UInt8 _G;
    UInt8 _B;
    UInt8 _W;
    UInt8 _C;
    int _clickCount;
    int _timeCount;
}

@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) NSMutableArray *groupArray;
@property (strong, nonatomic) CXSlider *lightSlider;
@property (strong, nonatomic) CXSlider *KFRSlider;
@property (strong, nonatomic) PaletteView *paletteView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *paletteBackView;
@property (weak, nonatomic) IBOutlet UIView *lightSliderBackView;
@property (weak, nonatomic) IBOutlet UIView *KFCSliderBackView;
@property (weak, nonatomic) IBOutlet UIButton *onOffBtn;
@property (weak, nonatomic) IBOutlet UILabel *lightLabel;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) NSArray *dataArray;


@end
static NSString *identifier = @"cell";
@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_build = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"版本号: %@",app_build];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([RSSICell class]) bundle:nil] forCellReuseIdentifier:identifier];
    [[[UpdateApp alloc] init] update:@"hsLED"]; // 更新APP版本
    _clickCount = 1;
//    int a = 0.937255 * 255.0;
//    int b = 0.937255 * 255.0;
//    int c = 0.956863 * 255.0;
//    NSLog(@"%d %d %d",a,b,c);
    
    CentralInstance;
    PeripheralInstance;
    _light = 1;
    _R = 255;
    _G = 255;
    _B = 255;
    _W = 0;
    _C = 255;
    self.tableView.hidden = YES;
//    CentralInstance.showLog = YES;
    [self addCenterNotifyName:msgDeviceUpdated];
    [self addCenterNotifyName:msgDeviceArrival];
    [self addCenterNotifyName:@"ReloadGroupName"];
    [self addCenterNotifyName:@"msgAppVersion"];
    [self addCenterNotifyName:@"dataArray"];
    
   NSArray *arr = [AppData getGroupNameArray];
    if (!arr) {
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i< 8; i++) {
            [array addObject:[NSString stringWithFormat:@"第%d组",i+1]];
        }
        [AppData saveGroupNameArray:array];
    }
    [self createHeaderView];
    
    int time = [AppData getTimer];
    _timeCount = time;
    switch (time) {
        case 0:
        {
            self.timerLabel.text = @"关";
        }
            break;
        case 1:case 2:case 4:
        {
            self.timerLabel.text = [NSString stringWithFormat:@"%d h",time];
        }
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.paletteView = [[PaletteView alloc] initWithFrame:self.paletteBackView.bounds];
        [self.paletteBackView addSubview:self.paletteView];
        [self.paletteBackView bringSubviewToFront:self.onOffBtn];
        self.paletteView.delegate = self;
        self.lightSlider = [[CXSlider alloc] initWithFrame:self.lightSliderBackView.bounds];
        [self.lightSlider setMinimumValue:0 maximumValue:1];
        self.lightSlider.delegate = self;
        [self.lightSlider setMinimumTrackColorWithColor:RGB(253, 233, 215, 1)];
        [self.lightSlider setMaximumTrackColorWithColor:[UIColor whiteColor]];
        [self.lightSliderBackView addSubview:self.lightSlider];
        [self.lightSlider setThumbWithThumbImage:[UIImage imageNamed:@"slider_round"]];
                
        self.KFRSlider = [[CXSlider alloc] initWithFrame:self.KFCSliderBackView.bounds];
        self.KFRSlider.delegate = self;
        [self.KFRSlider setThumbWithThumbImage:[UIImage imageNamed:@"slider_bar"]];
        [self.KFRSlider setMinimumValue:0 maximumValue:100];
        
        [self.KFRSlider setMaximumTrackColorWithColor:[UIColor clearColor]];
        [self.KFRSlider setMinimumTrackColorWithColor:[UIColor clearColor]];
        [self.KFCSliderBackView addSubview:self.KFRSlider];
    });
}

#pragma mark - Notify
- (void)messageNotify:(NSNotification *)notify {
    
    if ([notify.name isEqualToString:msgDeviceArrival]) {
        [self refreshUI];
    } else if ([notify.name isEqualToString:msgDeviceUpdated]) {
        [self refreshUI];
    }  else if ([notify.name isEqualToString:@"ReloadGroupName"]) {
        [self reloadGroupName];
    } else if ([notify.name isEqualToString:@"msgAppVersion"]) {
        [self processVersion];
    } else if ([notify.name isEqualToString:@"dataArray"]) {
        self.dataArray = notify.object;
        [self.tableView reloadData];
    }
}

- (void)processVersion
{
    if(APP.verState == 0)
    {
        UIAlertView * messageBox = [[UIAlertView alloc] initWithTitle: @"发现新版本."
                                                              message: @"当前版本还可以继续使用.\n但建议您更新至最新版本以获得更好的使用体验."
                                                             delegate: self
                                                    cancelButtonTitle: @"更新"
                                                    otherButtonTitles: @"取消", nil];
        [messageBox show];
    }
    else if(APP.verState == 1)
    {
        UIAlertView * messageBox = [[UIAlertView alloc] initWithTitle: @"发现新版本."
                                                              message: @"已发布新版本，当前版本已无法继续使用，点击更新。"
                                                             delegate: self
                                                    cancelButtonTitle: @"确定"
                                                    otherButtonTitles: nil];
        [messageBox show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView == nil) return;
    {
        switch (buttonIndex)
        {
            case 0:
                if(1)
                {
                    NSString *str = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/智能调光灯/id1299637105?l=zh&ls=1&mt=8"];
                    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                }
                break;
            case 1:
                break;
            default:
                break;
        }
    }
}


- (void)reloadGroupName
{
    NSArray *arr = [AppData getGroupNameArray];
    for (int i = 0; i < 8; i++) {
        UIView *view = self.headerView.subviews[i];
        UILabel *label = view.subviews[1];
        label.text = arr[i];
    }
}

#pragma mark - 取色板代理方法
-(void)palette:(PaletteView *)patetteView choiceColor:(UIColor *)color
{
    [self getRGBDictionaryByColor:color];
    
    UInt8 r = _R * _light;
    UInt8 g = _G * _light;
    UInt8 b = _B * _light;
 
   UInt8 mask = [self selectedGroup];
    if (mask == 0) {
        [self showHintLabel];
        return;
    }
    NSArray *arr = [self selectedGroupBtn];
    if (arr.count < 1) {
        return;
    }
    BleDevice *dev = [arr firstObject];
    [PeripheralInstance ble_setRGB:dev mask:[self selectedGroup] R:r G:g B:b warm:_W *_light cold:_C * _light];
}

#pragma mark - CXSliderDelegate
-(void)cxSlider:(CXSlider *)slider ValueChanged:(CGFloat)value {
    
    if (self.lightSlider == slider) {
        _light = value;
        self.lightLabel.text = [NSString stringWithFormat:@"亮度: %.0f%@",value*100,@"%"];
//        self.colorView.backgroundColor = RGB(_R, _G, _B, value);
        
        UInt8 r = _R * _light;
        UInt8 g = _G * _light;
        UInt8 b = _B * _light;
        UInt8 mask = [self selectedGroup];
        if (mask == 0) {
            [self showHintLabel];
            return;
        }
        NSArray *arr = [self selectedGroupBtn];
        BleDevice *dev = [arr firstObject];
        if (arr.count < 1)
        {
            return;
        }
        [ PeripheralInstance ble_setRGB:dev mask:mask R:r G:g B:b warm:_W * _light cold:_C * _light];
    } else if (self.KFRSlider == slider) {
        NSLog(@"=== %f", value);
        CGFloat vw = value * 255 / 100.0;
        NSArray *arr = [self selectedGroupBtn];
        BleDevice *dev = [arr firstObject];
        if (arr.count < 1)
        {
            return;
        }
        UInt8 r = _R * _light;
        UInt8 g = _G * _light;
        UInt8 b = _B * _light;
        _C = vw;
        _W = 0xff - vw;
        [PeripheralInstance ble_setRGB:dev mask:[self selectedGroup] R:r G:g B:b warm:_W * _light cold:_C * _light];
    }
    NSLog(@"%f",value);
}


- (void)refreshUI {
    for (int i = 0; i < (int)self.headerView.subviews.count; i++) {
        UIView *view = self.headerView.subviews[i];
        UILabel *label = view.subviews.lastObject;
        int count = [CentralInstance deviceCountInOfGroup:i+1];
        if (count == 0) {
            label.hidden = YES;
        } else {
            label.hidden = NO;
            label.text = [NSString stringWithFormat:@"%d",count];
        }
    }
}

- (NSArray *)selectedGroupBtn {
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < (int)self.headerView.subviews.count; i++) {
        UIView *view = self.headerView.subviews[i];
        UIButton *btn = view.subviews.firstObject;
        if (btn.selected == YES) {
            NSArray *arr = [CentralInstance getDeviceOfGroup:i+1];
            if (arr.count > 0)
            {
                [array addObjectsFromArray:arr];
            }
        }
    }
    return array;
}

- (UInt8)selectedGroup {
    UInt8 mask = 0;
    for (int i = 0; i < (int)self.headerView.subviews.count; i++) {
        UIView *view = self.headerView.subviews[i];
        UIButton *btn = view.subviews.firstObject;
        if (btn.selected == YES) {
            UInt8 b = 1 << (btn.tag - 1);
            mask |= b;
        }
    }
    return mask;
}

- (void)getRGBDictionaryByColor:(UIColor *)originColor
{
    CGFloat r = 0, g = 0, b = 0, a = 0;
    if ([self respondsToSelector:@selector(getRed:green:blue:alpha:)])
    {
        [originColor getRed:&r green:&g blue:&b alpha:&a];
    }
    else
    {
        const CGFloat *components = CGColorGetComponents(originColor.CGColor);
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }
    
    _R = r * 255.0;
    _G = g * 255.0;
    _B = b * 255.0;
    
//    self.RGBLabel.text = [NSString stringWithFormat:@"R:%d G:%d B:%d",_R,_G,_B];
//    self.colorView.backgroundColor = RGB(_R, _G, _B, _light);
}

- (void)createHeaderView {
   NSArray *groupNameArr = [AppData getGroupNameArray];
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, Width, 160)];
    [self.view addSubview:self.headerView];
    CGFloat W = Width / 4;
    CGFloat H = 70;
    UIButton *btn;
    UILabel *label;
    UIView *backView;
    UILabel *titleLabel;
    for (int i = 0; i < 8; i++)
    {
        int col = i % 4;
        int row = i / 4; // 行
        CGFloat btnX = col * W ;
        CGFloat btnY = 20 + row * (H+5);
        backView = [[UIView alloc] initWithFrame:CGRectMake(btnX, btnY, W, H)];
        [self.headerView addSubview:backView];
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 50, 50);
        btn.center = CGPointMake(backView.bounds.size.width/2, 25);
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"group_nor_%d",i+1]] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"group_sel_%d",i+1]] forState:UIControlStateSelected];
        btn.tag = i+1;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.selected = YES;
        label = [[UILabel alloc] initWithFrame:CGRectMake(btn.center.x + 15, btn.center.y - 15,20, 15)];
        
        label.backgroundColor = [UIColor redColor];
        label.layer.cornerRadius = 7.5;
        label.layer.masksToBounds = YES;
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
        titleLabel.center = CGPointMake(backView.bounds.size.width/2, 60);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:10];
        titleLabel.text = groupNameArr[i];
        
        
        int group = (int)[[CentralInstance getDeviceOfGroup:i+1] count];
        if (group > 0) {
            label.text = [NSString stringWithFormat:@"%d",group];
            label.hidden = NO;
        } else {
            label.text = nil;
            label.hidden = YES;
        }
        label.font = [UIFont boldSystemFontOfSize:10];
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.borderWidth = 1;
        label.textColor = [UIColor whiteColor];
        label.layer.borderColor = [UIColor whiteColor].CGColor;
        label.backgroundColor = RGB(117, 183, 252, 1);
        
        [backView addSubview:btn];
        [backView addSubview:titleLabel];
        [backView addSubview:label];
    
    }
}

- (void)showHintLabel
{
    if ([CentralInstance existGroup] == 0)  return;
    self.hintLabel.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.hintLabel.hidden = YES;
    });
}


#pragma mark - UIButtonClick
- (IBAction)timerBtnClick:(id)sender
{
    UInt8 mask = [self selectedGroup];
    if (mask == 0) {
        [self showHintLabel];
        return;
    }
    
    NSArray *arr = [self selectedGroupBtn];
    if (arr.count < 1)
    {
        return;
    }
    int time = 0;
    
    _timeCount ++;
    
    if (_timeCount > 3) {
        _timeCount = 0;
    }
    switch (_timeCount) {
        case 0:
            time = 0;
            break;
        case 1:
            time = 1;
            break;
        case 2:
            time = 2;
            break;
        case 3:
            time = 4;
            break;
        default:
            time = 0;
            break;
    }
    
    [AppData saveTimer:time];
    
   
    if (time > 0) {
        self.timerLabel.text = [NSString stringWithFormat:@"%d h",time];
    } else {
        self.timerLabel.text = @"关";
    }
    BleDevice *dev = [arr firstObject];
    [PeripheralInstance ble_timer:dev mask:[self selectedGroup] time:time*60];
}

- (IBAction)onSwitch:(UIButton *)sender {
    
    UInt8 mask = [self selectedGroup];
    if (mask == 0) {
        [self showHintLabel];
        return;
    }
    
    NSArray *arr = [self selectedGroupBtn];
    if (arr.count < 1)
    {
        return;
    }
    BleDevice *dev = [arr firstObject];
    [PeripheralInstance ble_switch:dev Mask:[self selectedGroup]];
}

- (IBAction)smallLightBtnClick:(id)sender {
    
    UInt8 mask = [self selectedGroup];
    if (mask == 0) {
        [self showHintLabel];
        return;
    }
    
    NSArray *arr = [self selectedGroupBtn];
    if (arr.count < 1)
    {
        return;
    }
    BleDevice *dev = [arr firstObject];
    [PeripheralInstance ble_small:dev mask:mask];
}
- (IBAction)onOffBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;

    if (sender.selected) {
        [sender setImage:[UIImage imageNamed:@"open_light"] forState:UIControlStateNormal];
    } else {
        [sender setImage:[UIImage imageNamed:@"close_light"] forState:UIControlStateNormal];
    }
    UInt8 mask = [self selectedGroup];
    if (mask == 0) {
        [self showHintLabel];
        return;
    }
    
    NSArray *arr = [self selectedGroupBtn];
    if (arr.count < 1)
    {
        return;
    }
    BleDevice *dev = [arr firstObject];
    
    if (dev.powerState == 0) {
        [PeripheralInstance ble_switch:dev mask:mask onOff:1];
    } else {
        [PeripheralInstance ble_switch:dev mask:mask onOff:0];
    }
}

// 10连击
- (IBAction)leftBtnClick:(id)sender {
    if (_clickCount == 10) {
        self.tableView.hidden = NO;
        [CentralInstance.logArray removeAllObjects];
        CentralInstance.showLog = YES;
    } else if (_clickCount == 20) {
        self.tableView.hidden = YES;
        CentralInstance.showLog = NO;
        _clickCount = 0;
    }
    _clickCount ++;
}

- (void)btnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
//    switch (sender.tag) {
//        case 1:
//        {
//            [PeripheralInstance ble_testA:0x01 B:0x01];
//        }
//            break;
//        case 2:
//        {
//            [PeripheralInstance ble_testA:0x01 B:0x02];
//
//        }
//            break;
//        case 3:
//        {
//            [PeripheralInstance ble_testA:0x01 B:0x03];
//
//        }
//            break;
//        case 4:
//        {
//            [PeripheralInstance ble_testA:0x02 B:0x00];
//
//        }
//            break;
//        case 5:
//        {
//            [PeripheralInstance ble_testA:0x02 B:0x01];
//            
//        }
//            break;
//        case 6:
//        {
//            [PeripheralInstance ble_testA:0x02 B:0x02];
//            
//        }
//            break;
//        case 7:
//        {
//            [PeripheralInstance ble_testA:0x02 B:0x03];
//            
//        }
//            break;
//        case 8:
//        {
//            [PeripheralInstance ble_testA:0x02 B:0x04];
//        }
//            break;
//        default:
//            break;
//    }
//    
}
- (IBAction)boundBtnClick:(id)sender {
    
}

- (IBAction)Add:(id)sender
{
    
}

- (NSMutableArray *)groupArray {
    if (!_groupArray) {
        _groupArray = [NSMutableArray array];
    }
    return _groupArray;
}

#pragma mark - UITableViewDelegate
// 多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
// 多少组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}
// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RSSICell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
   
    NSDate *date = self.dataArray[indexPath.row];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];;
    [formatter setDateFormat:@"HH:mm:ss"];
    cell.titleLabel.text = [formatter stringFromDate:date];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
