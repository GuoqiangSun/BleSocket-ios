

//
//  BluetoothModel.m
//  BluetoothSocket
//
//  Created by Mac on 2018/4/8.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "BluetoothModel.h"
#import "NSData+UTF8.h"
#import "ToolHandle.h"
#import <sys/utsname.h>

@interface BluetoothModel ()<WKScriptMessageHandler,HandlingDataModelDelegate>

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSMutableArray *peripheralArr;
@property (nonatomic, assign) CBCentralManagerState type;
@property (nonatomic, assign) BOOL reconnecting;
@property (nonatomic, strong) NSTimer *delayTimer;
@property (nonatomic, strong) NSTimer *heartTimer;
@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation BluetoothModel

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.type = CBCentralManagerStatePoweredOn;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothState:) name:@"updateState" object:nil];
    }
    return self;
}

- (NSArray *)funArr
{
    return @[
             @"errorHandlerRequest",//报错警告
             @"ModelTypeAdaptiveRequest",//查询手机机型
             @"systemLanguageRequest",//查询系统语言
             @"setSystemLanguageRequest",//设置系统语言
             @"addDeviceRequest", //添加设备
             @"isOpenBluetoothRequest",//是否打开蓝牙
             @"turnOnBlueToothRequest", //开启蓝牙
             @"equipmentSwitchRequest", //连接、断开设备
             @"isFirstBindingRequest",//是否首次连接
             @"deviceReconnectRequest",//重连
             @"closeSearchRequest", //结束搜索
            ];
}

- (NSDictionary *)funDic
{
    return @{
             @"errorHandlerRequest":@"errorHandlerRequest:",//报错警告
             @"systemLanguageRequest":@"systemLanguageRequest:",//查询系统语言
             @"ModelTypeAdaptiveRequest":@"ModelTypeAdaptiveRequest:",//查询手机机型
             @"setSystemLanguageRequest":@"setSystemLanguageRequest:",//设置系统语言
             @"addDeviceRequest":@"addDeviceRequest:",//添加设备
             @"isOpenBluetoothRequest":@"isOpenBluetoothRequest:",//是否打开蓝牙
             @"turnOnBlueToothRequest":@"turnOnBlueToothRequest:",//打开蓝牙
             @"equipmentSwitchRequest":@"equipmentSwitchRequest:",//连接断开蓝牙
             @"socketStatusRequest":@"socketStatusRequest:",//插座状态数据请求
             @"closeSearchRequest":@"closeSearchRequest:",//关闭搜索蓝牙
             @"isFirstBindingRequest":@"isFirstBindingRequest:",//是否第一次绑定
             @"deviceReconnectRequest":@"deviceReconnectRequest:",//重连
             };
}

#pragma mark 捕获异常
- (void)errorHandlerRequest:(NSDictionary *)object
{

    NSLog(@"................error.............>%@",object);
}

- (void)ModelTypeAdaptiveRequest:(NSDictionary *)object
{
    NSString *iphone = @"iPhone";
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    if ([platform isEqualToString:@"iPhone10,3"] ||
        [platform isEqualToString:@"iPhone10,6"] ||
        [platform isEqualToString:@"iPhone11,2"] ||
        [platform isEqualToString:@"iPhone11,4"] ||
        [platform isEqualToString:@"iPhone11,6"] ||
        [platform isEqualToString:@"iPhone11,8"]
        ){
        iphone = @"iPhoneX";
    }
    
    NSString *jsCode = [NSString stringWithFormat:@"ModelTypeAdaptiveResponse('%@')",iphone];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 获取当前语言
- (void)systemLanguageRequest:(NSDictionary *)object
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *lan ;
    
    if ([defaults objectForKey:LangauageType]) {
        lan = [defaults objectForKey:LangauageType];
    }else{
        NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
        NSString * preferredLang = [allLanguages objectAtIndex:0];
        if ([preferredLang hasPrefix:@"zh"]) {
            lan = @"zh";
        }else{
            lan = @"en";
        }
    }

    NSString *jsCode = [NSString stringWithFormat:@"systemLanguageResponse('%@')",lan];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 设置当前语言
- (void)setSystemLanguageRequest:(NSDictionary *)object
{
    NSString *language;
    language = [object objectForKey:@"language"];
//    NSInteger type = [[object objectForKey:@"state"] integerValue];
//    if ([language isEqualToString:@"zh"]) {
//
//    }else if([language isEqualToString:@"en"]){
//
//    }else if (type == 0){
//        language = @"zh";
//    }else{
//        language = @"en";
//    }
    if (language.length) {
        [[NSUserDefaults standardUserDefaults] setObject:language forKey:LangauageType];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSString *jsCode = [NSString stringWithFormat:@"setSystemLanguageResponse(%d,'%@')",true,language];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}


#pragma mark 请求获取蓝牙设备列表
- (void)addDeviceRequest:(NSDictionary *)object
{
    NSLog(@"addDeviceRequest........");
    [BluetoothManager.shareInstance scanOrStop:true];
    if (!self.peripheralArr.count && !self.reconnecting) {
        [self refreshPeripheral];
    }
    if (_delayTimer) {
        [_delayTimer invalidate];
        _delayTimer = nil;
    }
    _delayTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(notFound) userInfo:nil repeats:false];
    [[NSRunLoop currentRunLoop] addTimer:_delayTimer forMode:NSRunLoopCommonModes];
}

#pragma mark 蓝牙搜索列表返回
- (void)refreshPeripheralList:(NSMutableArray<CBPeripheral *> *)peripheralList
{
    if(self.reconnecting){
        return;
    }
    self.peripheralArr = [peripheralList copy];
    [self refreshPeripheral];
}

#pragma mark 刷新蓝牙列表界面
- (void)refreshPeripheral
{
    NSLog(@"addDeviceResponse........");
    NSDictionary *dic = @{};
    NSInteger type = self.type;
    if (self.type != CBCentralManagerStatePoweredOn) {
        type = 1;
    }else if (!_peripheralArr.count) {
        type = 2;
    }else{
        type = 4;
    }
    if (self.peripheralArr.count) {
        CBPeripheral *peropheral = [self.peripheralArr lastObject];
        NSString *identfiy = [[NSString alloc] initWithFormat:@"%@",peropheral.identifier];
        NSInteger state = peropheral.state == CBPeripheralStateConnected?1:0;
        NSString *name = peropheral.name.length?peropheral.name:@"null";
        dic  =  @{
                  @"name": name,
                  @"mac": identfiy,
                  @"state": @(state),
                  @"signal":@(false),
                  };
    }
    
    NSString*json = [ToolHandle toJsonString:dic];
    if (type != 4) {
        json = @"";
    }
    NSString *jsCode = [NSString stringWithFormat:@"addDeviceResponse(%ld,'%@')",(long)type,json];
    NSLog(@"...................................>%@",jsCode);

    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 未搜索到蓝牙列表
- (void)notFound
{
    if (_delayTimer) {
        [_delayTimer invalidate];
        _delayTimer = nil;
    }
    if (self.type == CBCentralManagerStatePoweredOn && (!self.peripheralArr.count || self.peripheralArr ==nil)) {
        NSString *jsCode = [NSString stringWithFormat:@"addDeviceResponse(%d,'%@')",3,@""];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
    }
}

#pragma mark 请求打开蓝牙开关
- (void)turnOnBlueToothRequest:(NSDictionary *)object
{
    NSLog(@"turnOnBlueToothRequest..............");
    if (self.openBluetoothSetting) {
        self.openBluetoothSetting();
    }
}

#pragma mark 是否打开蓝牙
- (void)isOpenBluetoothRequest:(NSDictionary *)obejct
{
    NSLog(@"isOpenBluetoothRequest.................");
//    [self performSelector:@selector(bluetoothStatus) withObject:nil afterDelay:0.5];
    [self bluetoothStatus];
   
}

- (void)bluetoothStatus
{
    NSString *jsCode = [NSString stringWithFormat:@"isOpenBluetoothResponse(%d)",self.type == CBCentralManagerStatePoweredOn];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    NSLog(@"isOpenBluetoothResponse...................%d",self.type == CBCentralManagerStatePoweredOn);
}

#pragma mark 蓝牙状态
- (void)bluetoothState:(NSNotification *)noti
{
    self.type = (CBCentralManagerState)[[noti.userInfo objectForKey:@"state"] integerValue];
    if (!self.peripheralArr.count && !self.reconnecting) {
        [self refreshPeripheral];
    }
    
    if (self.type == CBCentralManagerStatePoweredOff) {
        if (self.peripheral) {
            [[BluetoothManager shareInstance] disconnectedPeripheral:self.peripheral];
        }else{
            //            [self bluetoothStatus];
        }
    }
    
    NSString *jsCode = [NSString stringWithFormat:@"blueToothStateResponse(%d)",self.type == CBCentralManagerStatePoweredOn];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
     NSLog(@"blueToothStateResponse...................%d",self.type == CBCentralManagerStatePoweredOn);
}


#pragma mark 手否首次绑定
- (void)isFirstBindingRequest:(NSDictionary *)object
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"isFirstBindingRequest.................");
        
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:StorePerpheral];
        NSString *json = @"";
        BOOL res = true;
        if (dic) {
            [BluetoothManager shareInstance].reconnect = true;
            [[BluetoothManager shareInstance] scanOrStop:true];
            self.reconnecting = true;
            res = false;
            json = [ToolHandle toJsonString:dic];
        }
        NSString *jsCode = [NSString stringWithFormat:@"isFirstBindingResponse(%d,'%@')",res,json];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {

        }];
    });
}

#pragma mark 重连
- (void)deviceReconnectRequest:(NSDictionary *)object
{
    [self performSelector:@selector(deviceReconnectResult:) withObject:object[@"mac"] afterDelay:30];
}

- (void)deviceReconnectResult:(NSString *)mac
{
    int res = 0;
    if (self.peripheral) {
        res = 1;
        self.reconnecting = false;
    }else{
        [[BluetoothManager shareInstance] scanOrStop:false];
        //为了解决搜索的延时0.5秒列表回调冲突
        [self performSelector:@selector(delayReconnectResult:) withObject:mac afterDelay:0.5];
    }
}

- (void)delayReconnectResult:(NSString *)mac
{
    self.reconnecting = false;
    NSString *jsCode1 = [NSString stringWithFormat:@"equipmentSwitchResponse('%@',%d,%d)",mac,false,true];
    [self.web evaluateJavaScript:jsCode1 completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
//    NSString *jsCode = [NSString stringWithFormat:@"addDeviceResponse(%d,'%@')",3,@""];
//    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
//        
//    }];
}

#pragma mark 蓝牙连接回调
- (void)connectedPeripheral:(CBPeripheral *)peripheral
{
    self.reconnecting = false;
    [BluetoothManager shareInstance].reconnect = false;     //还未重连接上次蓝牙设备 连接上了新设备取消重连设置
    self.peripheral = peripheral;
    NSString *identfiy = [[NSString alloc] initWithFormat:@"%@",peripheral.identifier];
    NSString *jsCode = [[NSString alloc] initWithFormat:@"equipmentSwitchResponse('%@',%d,%d)",identfiy,1,true];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    NSLog(@"蓝牙连接成功...............");
    if (self.timer) {
        dispatch_cancel(self.timer);
    }
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC));
    dispatch_source_set_timer(_timer, start, 5 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        [self queryCalibrationTime];
        dispatch_cancel(_timer);
    });
    dispatch_resume(_timer);
//    [self performSelector:@selector(queryCalibrationTime) withObject:nil afterDelay:3.0];
    [self startHeartBeatTimer];
}

#pragma mark 蓝牙断开回调
- (void)disconnectedPeripheral:(CBPeripheral *)peripheral
{
    self.peripheral = nil;
    NSString *identfiy = [[NSString alloc] initWithFormat:@"%@",peripheral.identifier];
    NSString *jsCode = [[NSString alloc] initWithFormat:@"equipmentSwitchResponse('%@',%d,%d)",identfiy,0,true];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    NSLog(@"蓝牙断开连接...............");
    if (_heartTimer) {
        [_heartTimer invalidate];
        _heartTimer = nil;
    }
}

#pragma mark 停止搜索蓝牙
- (void)closeSearchRequest:(NSDictionary *)object
{
    [BluetoothManager.shareInstance scanOrStop:false];
}


#pragma mark 外设插座蓝牙连接控制
- (void)equipmentSwitchRequest:(NSDictionary *)object
{
    NSLog(@"equipmentSwitchRequest................");
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"蓝牙控制请求" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alert show];
    if (!self.peripheralArr.count && self.peripheral && self.peripheral.state != CBPeripheralStateConnected) {
        self.peripheralArr = [NSMutableArray arrayWithObject:self.peripheral];
    }
    NSString *mac = [object objectForKey:@"mac"];
    NSInteger state = [[object objectForKey:@"state"] integerValue];
    if (state == 0 && !self.peripheral) {
        NSString *jsCode = [[NSString alloc] initWithFormat:@"equipmentSwitchResponse('%@',%d,%d)",mac,0,true];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
        return;
    }

    for (CBPeripheral *per in self.peripheralArr) {
        NSString *identify = [[NSString alloc] initWithFormat:@"%@",per.identifier];
        if ([identify isEqualToString:mac]) {
            if (state) {
                [BluetoothManager.shareInstance connectedPeripheral:per];
            }else{
                [BluetoothManager.shareInstance disconnectedPeripheral:per];
            }
            
        }
    }
}

#pragma mark 查询时间
- (void)queryCalibrationTime
{
    int8_t type= 0x02;
    int8_t cmd = 0x0f;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    
    data = [ToolHandle getPacketData:data];
    [self sendDataWithMac:@"" data:data];
}

- (void)queryCalibrationTimeResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSData *data = (NSData *)[object objectForKey:@"data"];
    Byte *bytes = (Byte *)[data bytes];
    if (data.length>16) {
        NSInteger year = bytes[8]+2000;
        NSInteger week = bytes[9];
        NSInteger month = bytes[10];
        NSInteger day = bytes[11];
        NSInteger hour = bytes[12];
        NSInteger min = bytes[13];
        CGFloat sec = bytes[14];
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDate *now;
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
        NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        now=[NSDate date];
        comps = [calendar components:unitFlags fromDate:now];
        
        NSInteger realweek = [comps weekday] - 1;
        if (realweek == 0) {
            realweek = 7;
        }
        
        NSInteger year1 = [comps year];
        NSInteger week1 = realweek;
        NSInteger month1 = [comps month];
        NSInteger day1 = [comps day];
        NSInteger hour1 = [comps hour];
        NSInteger min1 = [comps minute];
        CGFloat sec1 = (CGFloat)[comps second];
        
//        if (year1 - year !=0 ||
//            week1 - week != 0 ||
//            month1 - month != 0 ||
//            day1 - day != 0 ||
//            hour1 - hour != 0 ||
//            min1 - min != 0 ||
//            fabs(sec1 - sec) > 3.0
//            ) {
            [self calibrationTime];
//        }
    }
}

#pragma mark 校准时间
- (void)calibrationTime
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *now;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    now=[NSDate date];
    comps = [calendar components:unitFlags fromDate:now];
    
    NSInteger realweek = [comps weekday] - 1;
    if (realweek == 0) {
        realweek = 7;
    }
    
    int8_t type= 0x02;
    int8_t cmd = 0x03;
    int8_t year = (int8_t)([comps year]-2000);
    int8_t week = (int8_t)realweek;
    int8_t month = (int8_t)[comps month];
    int8_t day = (int8_t)[comps day];
    int8_t hour = (int8_t)[comps hour];
    int8_t min = (int8_t)[comps minute];
    int8_t sec = (int8_t)[comps second];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:year]];
    [data appendData:[self getData:week]];
    [data appendData:[self getData:month]];
    [data appendData:[self getData:day]];
    [data appendData:[self getData:hour]];
    [data appendData:[self getData:min]];
    [data appendData:[self getData:sec]];
    
    data = [ToolHandle getPacketData:data];
    [self sendDataWithMac:@"" data:data];
}

- (void)calibrationTimeResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
//    [self queryCalibrationTime];
}

#pragma mark 心跳包
- (void)startHeartBeatTimer
{
    if (_heartTimer) {
        [_heartTimer invalidate];
        _heartTimer = nil;
    }
    _heartTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(sendHeartBeat) userInfo:nil repeats:true];
}

- (void)sendHeartBeat
{
    uint8_t type = 0x01;
    uint8_t cmd = 0x01;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    data = [ToolHandle getPacketData:data];
    [self sendDataWithMac:@"" data:data];
}

- (void)registFunctionWithWeb:(WKWebView *)web
{
    self.web = web;
    __weak typeof(self) weakSelf = self;
    [self.funArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[weakSelf.web configuration].userContentController addScriptMessageHandler:self name:obj];
    }];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([self.funDic.allKeys containsObject:message.name]) {
        SEL sel = NSSelectorFromString([self.funDic objectForKey:message.name]);
        if ([self respondsToSelector:sel]) {
            [[BluetoothManager shareInstance] regeistDelegate:self];
            [self performSelector:sel withObject:message.body];
        }
    }
}

@end
