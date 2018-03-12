//
//  ViewControllerGroup.m
//  Peripheral
//
//  Created by apple on 18/12/17.
//  Copyright © 2017年 apple. All rights reserved.
//
#define WhiteColor [UIColor whiteColor]
#define EnableColor RGB(255, 255, 255, 0.8)

#import "ViewControllerGroup.h"
#import "GroupCell.h"

#import "SelectedGroupController.h"
#import "GroupHeaderView.h"
#import "HintView.h"

@interface ViewControllerGroup ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UIAlertViewDelegate,GroupHeaderViewDelegate>
{
    int _signTableViewType;
}
@property (weak, nonatomic) IBOutlet UIButton *groupBtn;
@property (weak, nonatomic) IBOutlet UILabel *noLabel;

@property (strong, nonatomic) NSTimer *timer;

@property (assign, nonatomic) float totalTime;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@property (assign, nonatomic) int selectedGroup;
@property (strong, nonatomic) HintView *hintView;


@end

static NSString *identifier1      = @"cell";
static NSString *headerIdentifier = @"headerCell";

@implementation ViewControllerGroup

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCenterNotifyName:msgDeviceArrival];
    [self addCenterNotifyName:msgDeviceUpdated];
    
    self.cancelBtn.hidden = YES;
    
    [self btnTitleColorStyle:self.groupBtn];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([GroupCell class]) bundle:nil] forCellReuseIdentifier:identifier1];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([GroupHeaderView class]) bundle:nil] forHeaderFooterViewReuseIdentifier:headerIdentifier];
    self.hintView = [HintView hintViewInstance];
    self.hintView.frame = KeyWindow.bounds;
    self.hintView.hidden = YES;
    [KeyWindow addSubview:self.hintView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    for (BleDevice *dev in CentralInstance.deviceList) {
        dev.selectFlag = 0;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeTimer];
}

- (void)btnTitleColorStyle:(UIButton *)btn {
    if (btn.userInteractionEnabled == NO) {
        [btn setTitleColor:EnableColor forState:UIControlStateNormal];
    } else {
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

#pragma mark - UIButtonClick

- (IBAction)groupBtnClick:(id)sender
{
    if (_signTableViewType == 0) {
        self.cancelBtn.hidden = NO;
        [self.groupBtn setTitle:@"确定" forState:UIControlStateNormal];
        _signTableViewType = 1;
        [self.tableView reloadData];
    } else {
        if ([CentralInstance selectedFlag] == 0)  return;
        SelectedGroupController *selVC =  GetViewController(@"SelectedGroupController");
        selVC.block = ^(id data) {
            
            NSLog(@"group data = %@",data);
            if ([data intValue] == 0) {
                return;
            }
            NSMutableArray *array = [NSMutableArray array];
            for (BleDevice *ble in CentralInstance.deviceList) {
                if (ble.selectFlag == 1)
                {
                    ble.signSend = NO;
                    ble.newGroupID = [data intValue];
                    [array addObject:ble];
                }
            }
            self.selectedGroup = [data intValue];
            [self startTimer:array.count * 1.5 style:1];
            [self.hintView showTitle:@"正在分组..."];
        };
        [self presentWithViewController:selVC animated:NO completion:nil];
    }
}

- (IBAction)backBtnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelBtnClick:(id)sender {
    _signTableViewType = 0;
    [self.groupBtn setTitle:@"分组" forState:UIControlStateNormal];
    self.cancelBtn.hidden = YES;
    
    for (BleDevice *ble in CentralInstance.deviceList) {
        ble.selectFlag = NO;
        ble.signSend = NO;
    }
    [self.tableView reloadData];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSMutableArray *array = [NSMutableArray array];
        for (BleDevice *ble in CentralInstance.deviceList) {
            if (ble.selectFlag == 1)
            {
                ble.newGroupID = (int)buttonIndex;
                ble.signSend = NO;
                [array addObject:ble];
            }
        }
        [self startTimer:array.count * 1.5 style:2];
        [self.hintView showTitle:@"正在解散组..."];
        
    } else {
        for (BleDevice *ble in CentralInstance.deviceList) {
            ble.selectFlag = 0;
            ble.signSend = NO;
        }
    }
}
#pragma mark - Notify
- (void)messageNotify:(NSNotification *)notify {
    if ([notify.name isEqualToString:msgDeviceUpdated]) {
        [self.tableView reloadData];
        if ([CentralInstance selectedFlag] == 0) {
            self.cancelBtn.hidden = NO;
        } else {
            self.cancelBtn.hidden = YES;
        }
        
    } else if ([notify.name isEqualToString:msgDeviceArrival]) {
        [self.tableView reloadData];
        if ([CentralInstance selectedFlag] == 0) {
            self.cancelBtn.hidden = NO;
        } else {
            self.cancelBtn.hidden = YES;
        }
    }
}

- (void)setBtnStyle:(UIButton *)btn titleColor:(UIColor *)color enable:(BOOL)enable
{
    [btn setTitleColor:color forState:UIControlStateNormal];
    btn.userInteractionEnabled = enable;
}

- (void)startTimer:(float)time style:(int)style {
    [self removeTimer];
    self.totalTime = time;

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(tick:) userInfo:@(style) repeats:YES];
    NSLog(@"%s %d",__func__,__LINE__);

}

- (void)tick:(NSTimer *)timer
{
    NSLog(@"%s %d",__func__,__LINE__);
    int style = [timer.userInfo intValue];
    self.totalTime -= 1.5;
    
    if (style == 1)
    {
        for (BleDevice *ble in CentralInstance.deviceList)
        {
            if (ble.selectFlag == 1) {
                NSLog(@"address = %d",ble.address);
                if (ble.signSend == YES) {
                    continue;
                }
                ble.signSend = YES;
                ble.selectFlag = 0;
                [PeripheralInstance ble_setGroup:ble group:self.selectedGroup];
                break;
            }
        }
    } else if (style == 2)  {
        for (BleDevice *ble in CentralInstance.deviceList)
        {
            if (ble.selectFlag == 1) {
                if (ble.signSend == YES) {
                    continue;
                }
                ble.signSend = YES;
                ble.selectFlag = 0;
                [PeripheralInstance ble_disbandGroup:ble];
                break;
            }
        }
    }
    if (self.totalTime == 0)
    {
        for (BleDevice *dev in CentralInstance.deviceList) {
            dev.selectFlag = 0;
        }
        [self.tableView reloadData];
        [self removeTimer];
        [self.hintView hide];
    }
    [self.tableView reloadData];
}

- (void)removeTimer
{
    if (self.timer != nil)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - GroupHeaderViewDelegate
- (void)groupHeaderViewDeleteCell:(GroupHeaderView *)headCell
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定删除分组" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    int group = (int)headCell.checkBtn.tag;
    NSArray *array = [CentralInstance allGroupDevice];
    if (array.count > group) {
        NSArray *arr = array[group];
        for (int i = 0; i < arr.count; i++) {
           BleDevice *dev = arr[i];
            for (BleDevice *ble in CentralInstance.deviceList) {
                if (dev.address == ble.address) {
                    ble.selectFlag = 1;
                    break;
                }
            }
        }
    }
}

#pragma mark - UITableViewDelegate
// 多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *array = [CentralInstance allGroupDevice];
    return [array[section] count];
}

// 多少组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSMutableArray *array = [CentralInstance getGroupList];
    if (array.count == 0) {
        self.noLabel.hidden = NO;
    } else {
        self.noLabel.hidden = YES;
    }
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    GroupHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
    header.delegate = self;
    if (_signTableViewType == 0) {
        header.checkBtn.hidden = NO;
        self.cancelBtn.hidden = YES;
    } else {
        header.checkBtn.hidden = YES;
        self.cancelBtn.hidden = NO;
    }
    NSArray *groupArr = [CentralInstance allGroupDevice];
    NSArray *rowArr = [groupArr objectAtIndex:section];
    BleDevice *dev = [rowArr objectAtIndex:0];
    header.checkBtn.tag = section;
    if (dev.groupID == 0) {
        header.titleLabel.text = [NSString stringWithFormat:@"未分组  %d个",(int)[CentralInstance getNoSetGroup].count];
        [header.checkBtn setImage:nil forState:UIControlStateNormal];
        header.checkBtn.hidden = YES;
    } else {
        int count =  (int)[[CentralInstance getGroupCount:dev.groupID] count];
        header.titleLabel.text = [NSString stringWithFormat:@"第%d组 %d个",dev.groupID, count];
    }
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
    NSArray *array = [CentralInstance allGroupDevice];
    NSArray *rowArr = array[indexPath.section];
    if (rowArr.count == 1) {
        cell.cellBorderType = cellTypeOnlyOne;
    } else if (rowArr.count == 2) {
        if (indexPath.row == 0) {
            cell.cellBorderType = cellTypeTop;
        } else if (indexPath.row == 1) {
            cell.cellBorderType = cellTypeBottom;
        }
    } else if (rowArr.count > 2){
        if (indexPath.row == 0) {
            cell.cellBorderType = cellTypeTop;
        } else if (indexPath.row == rowArr.count-1) {
            cell.cellBorderType = cellTypeBottom;
        } else {
            cell.cellBorderType = cellTypeMiddle;
        }
    }
    BleDevice *dev  = rowArr[indexPath.row];
    cell.titleLabel.text = [self titleName:dev];
    if (dev.groupID == 0) {
        cell.imgView.image = [UIImage imageNamed:@"small_nor_4"];
    } else {
        cell.imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"group_nor_%d",dev.groupID]];
    }
    if (_signTableViewType == 0) {
        cell.checkBtn.hidden = YES;
    } else {
        cell.checkBtn.hidden = NO;
        if (dev.selectFlag == 0) {
            cell.checkBtn.selected = NO;
        } else {
            cell.checkBtn.selected = YES;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_signTableViewType == 0) {
        return;
    }
    NSArray *array = [CentralInstance allGroupDevice];
    NSArray *devArr = array[indexPath.section];
    BleDevice *dev = devArr[indexPath.row];
    NSLog(@"%d",dev.selectFlag);
    if (dev.selectFlag == 0)
    {
        dev.selectFlag = 1;
    } else
    {
        dev.selectFlag = 0;
    }
    [tableView reloadData];
}

- (NSString *)titleName:(BleDevice *)dev
{
    return  [NSString stringWithFormat:@"%d-%02X%02X%02X-%d", dev.companySet, (dev.address >> 16) & 0xff, (dev.address >> 8) & 0xff , dev.address & 0xff, dev.groupID];
}
- (void)dealloc
{
    NSLog(@"%s %d",__func__,__LINE__);
}
@end
