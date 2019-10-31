//
//  ViewController.m
//  BluetoothSocket
//
//  Created by Mac on 2018/4/8.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "MainViewController.h"
#import <WebKit/WebKit.h>
#import "BluetoothManager.h"
#import "BluetoothModel.h"
#import "BaseControlModel.h"
#import "SettingModel.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UncaughtExceptionHandler.h"

@interface MainViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>
{
    CGPoint keyboardPoint;
}
@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong) BluetoothManager *bluetoothManager;
@property (nonatomic, strong) BluetoothModel *bluetoothModel;
@property (nonatomic, strong) BaseControlModel *baseControlModel;
@property (nonatomic, strong) UIView *statusView;
@property (nonatomic, strong) SettingModel *settingModel;
@property (nonatomic, assign) NSInteger type;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.statusView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    self.statusView.backgroundColor = [UIColor colorWithRed:78/255.0 green:163/255.0 blue:254/255.0 alpha:1];
    [self.view addSubview:self.statusView];
    
    WKWebViewConfiguration *wkWebConfiguration = [[WKWebViewConfiguration alloc] init];
    self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) configuration:wkWebConfiguration];
//    self.wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:wkWebConfiguration];
    self.wkWebView.scrollView.bounces = false;
    self.wkWebView.navigationDelegate = self;
    self.wkWebView.UIDelegate = self;
    [self.view addSubview:self.wkWebView];
    [self.bluetoothModel registFunctionWithWeb:self.wkWebView];
    [self.baseControlModel registFunctionWithWeb:self.wkWebView];
    [self.settingModel registFunctionWithWeb:self.wkWebView];
    NSString *path = [[[[NSBundle mainBundle]bundlePath] stringByAppendingPathComponent:@"BluetoothSocketDist"] stringByAppendingPathComponent:@"index.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
    [self.wkWebView loadRequest:request];
    
    if (@available(iOS 11.0, *)) {
        UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    

//    [[NSNotificationCenter defaultCenter] removeObserver:self.wkWebView name:UIKeyboardWillHideNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self.wkWebView name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self.wkWebView name:UIKeyboardWillChangeFrameNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self.wkWebView name:UIKeyboardDidChangeFrameNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    //监听当键将要退出时
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
//    
}

//当键盘出现
- (void)keyboardWillShow:(NSNotification *)notification
{
    //获取键盘的高度
    keyboardPoint = self.wkWebView.scrollView.contentOffset;
    NSLog(@"...........键盘出现......%@",NSStringFromCGPoint(self.wkWebView.scrollView.contentOffset));
}

//当键退出
- (void)keyboardWillHide:(NSNotification *)notification
{
    //获取键盘的高度
//    if (keyboardPoint.x || keyboardPoint.y) {
//        CGPoint point = self.wkWebView.scrollView.contentOffset;
//        self.wkWebView.scrollView.contentOffset = CGPointMake(point.x-keyboardPoint.x, point.y-keyboardPoint.y);
//    }else{
        self.wkWebView.scrollView.contentOffset = CGPointMake(0, 0);
//    }
    NSLog(@"...........键盘收起......%@",NSStringFromCGPoint(self.wkWebView.scrollView.contentOffset));
    
}



- (BluetoothModel *)bluetoothModel
{
    __weak typeof(self) weakSelf = self;
    if (!_bluetoothModel) {
        _bluetoothModel = [BluetoothModel shareInstance];
    }
    _bluetoothModel.openBluetoothSetting = ^{
        [weakSelf openBluetooth];
    };
    return _bluetoothModel;
}

- (BaseControlModel *)baseControlModel
{
    if (!_baseControlModel) {
        _baseControlModel = [BaseControlModel shareInstance];
    }
    return _baseControlModel;
}

- (SettingModel *)settingModel
{
    if (!_settingModel) {
        _settingModel = [SettingModel shareInstance];
    }
    return _settingModel;
}


- (void)bluetoothState:(NSNotification *)noti
{
    NSLog(@"蓝牙状态更新");
    self.type = [[noti.userInfo objectForKey:@"state"] integerValue];
}

- (void)openBluetooth
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Turn On Bluetooth to Allow “蓝牙插座” to Connect to Accessories" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *setting = [UIAlertAction actionWithTitle:@"Setting" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:true completion:nil];
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:true completion:nil];
    }];
    [alertVC addAction:setting];
    [alertVC addAction:ok];
    [self presentViewController:alertVC animated:true completion:nil];
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    
    self.bluetoothManager = [BluetoothManager shareInstance];
    [self.bluetoothManager regeistDelegate:self.bluetoothModel];
//    [self performSelector:@selector(delayState) withObject:nil afterDelay:2.0];
    NSString *jsCode = [NSString stringWithFormat:@"isOpenBluetoothResponse(%d)",true];
    [self.wkWebView evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
    [self.bluetoothModel ModelTypeAdaptiveRequest:@{}];
    
}

- (void)delayState
{
    NSString *jsCode = [NSString stringWithFormat:@"isOpenBluetoothResponse(%d)",self.type==5];
    [self.wkWebView evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    //    NSURLRequest *request = navigationAction.request;
    WKNavigationActionPolicy actionPolicy = WKNavigationActionPolicyAllow;
    actionPolicy = WKNavigationActionPolicyAllow;
    //这句是必须加上的，不然会异常
    decisionHandler(actionPolicy);
}


- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    completionHandler(YES);
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler
{
    completionHandler(@"完成");
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertView *aletView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"cancle" otherButtonTitles:nil, nil];
    [aletView show];
    completionHandler();
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
