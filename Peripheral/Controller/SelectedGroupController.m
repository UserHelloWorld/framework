//
//  SelectedGroupController.m
//  Peripheral
//
//  Created by apple on 22/12/17.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "SelectedGroupController.h"
#import "UIImage+Color.h"
#import "AppData.h"

@interface SelectedGroupController ()

@property (weak, nonatomic) IBOutlet UIView *selectedView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (strong, nonatomic) UIButton *lastBtn;

@end

@implementation SelectedGroupController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.textField];

    [self addCenterNotifyName:msgDeviceArrival];
    [self addCenterNotifyName:msgDeviceUpdated];
    
    UIColor *color = RGB(117, 183, 252, 1);
    [self.cancelBtn setBackgroundImage:[UIImage buttonImageBounds:self.cancelBtn.bounds color:color] forState:UIControlStateNormal];
    [self.confirmBtn setBackgroundImage:[UIImage buttonImageBounds:self.confirmBtn.bounds color:color] forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyBoard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyBoard:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textField resignFirstResponder];
}

- (void)showKeyBoard:(NSNotification *)noti
{
    NSDictionary *userInfo = [noti userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    int height = keyboardRect.size.height;
    if (self.bottomConstraint.constant < height) {
        [UIView animateWithDuration:0.25 animations:^{
            self.bottomConstraint.constant = height;
            [self.view layoutIfNeeded];
        }];
    }

}
- (void)hideKeyBoard:(NSNotification *)noti {
   
    [UIView animateWithDuration:0.25 animations:^{
        self.bottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
    
}


-(void)textFieldChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    NSString *lang = [textField.textInputMode primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > 5) {
                textField.text = [toBeString substringToIndex:5];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > 6) {
            textField.text = [toBeString substringToIndex:6];
        }
    }
}

- (void)messageNotify:(NSNotification *)notify {
    if ([notify.name isEqualToString:msgDeviceUpdated]) {
        if ([CentralInstance selectedFlag] == 0)
        {
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    } else if ([notify.name isEqualToString:msgDeviceArrival]) {
        if ([CentralInstance selectedFlag] == 0)
        {
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CGFloat W = self.selectedView.bounds.size.width / 4;
    CGFloat H = 50;
    UIButton *btn;
    UIView *backView;
    for (int i = 0; i < 8; i++)
    {
        int col = i % 4;
        int row = i / 4; // 行
        CGFloat btnX = col * W ;
        CGFloat btnY = 10 + row * (H+10);
        backView = [[UIView alloc] initWithFrame:CGRectMake(btnX, btnY, W, H)];
        [self.selectedView addSubview:backView];
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 50, 50);
        btn.center = CGPointMake(backView.bounds.size.width/2, backView.bounds.size.height/2);
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"group_nor_%d",i+1]] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"group_sel_%d",i+1]] forState:UIControlStateSelected];
        btn.tag = i+1;

        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:btn];
    }
}

- (IBAction)cancelBtnClick:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)confirmBtnClick:(id)sender {
    
    if (self.lastBtn.tag < 9 && self.lastBtn.tag > 0) {
        if (self.textField.text.length > 1)  {
            NSArray *arr = [AppData getGroupNameArray];
            NSMutableArray *array = [NSMutableArray array];
            [array addObjectsFromArray:arr];
            [array replaceObjectAtIndex:self.lastBtn.tag-1 withObject:self.textField.text];
            [AppData saveGroupNameArray:array];
            PostNotification(@"ReloadGroupName", nil);
        }
    }
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.block) {
            self.block(@(self.lastBtn.tag));
        }
    }];
}

- (void)btnClick:(UIButton *)btn {
    self.lastBtn.selected = NO;
    btn.selected = !btn.selected;
    self.lastBtn = btn;
}
- (void)dealloc
{
    NSLog(@"%s %d",__func__,__LINE__);

}
@end
