//
//  DeclareViewController.m
//  Peripheral
//
//  Created by apple on 10/03/18.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "DeclareViewController.h"
#import <WebKit/WebKit.h>

@interface DeclareViewController ()<WKNavigationDelegate>

@end

@implementation DeclareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, Width, Height - 64)];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.huazhicloud.com/home/app/index/appid/hsLED.html"]]];
    webView.navigationDelegate = self;
    [self.view addSubview:webView];
}

- (IBAction)backBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"开始加载");
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"完成");
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)dealloc
{
    NSLog(@"%s %d",__func__,__LINE__);

}

@end
