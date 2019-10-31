//
//  BaseControlModel.m
//  BluetoothSocket
//
//  Created by Mac on 2018/7/16.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "BaseControlModel.h"

@interface BaseControlModel ()<WKScriptMessageHandler>

@property (nonatomic, strong) NSMutableDictionary *reportDic;
@property (nonatomic, strong) NSMutableDictionary *temperAndHumiDic;
@property (nonatomic, strong) NSMutableDictionary *powerAndCostDic;

@end

@implementation BaseControlModel

- (instancetype)init
{
    if (self = [super init]) {
        self.temperAndHumiDic = [[NSMutableDictionary alloc] init];
        [self.temperAndHumiDic setObject:@{
                                           @"currentValue": @(0),
                                           @"hotAlarmValue": @(0),
                                           @"hotAlarmSwitch": @(false),
                                           @"codeAlarmValue": @(0),
                                           @"codeAlarmSwitch": @(false)
                                           } forKey:@"temperature"];
        self.powerAndCostDic = [[NSMutableDictionary alloc] init];
        //    NSDictionary *dic = @{
        //                          @"power": @{
        //                                  @"value": @(0),
        //                                  @"averageValue": @(0),
        //                                  @"maximumValue": @(0)
        //                                  },
        //                          @"voltage": @(0),
        //                          @"electricity": @(0),
        //                          @"frequency": @(0),
        //                          @"temperature": @{
        //                                  @"value": @(0),
        //                                  @"alarmValue": @(0)
        //                                  },
        //                          @"humidity": @{
        //                                  @"value": @(0),
        //                                  @"alarmValue": @(0)
        //                                  },
        //                          @"weight": @(0),
        //                          @"cost": @(0),
        //                          @"countDown": @(0)
        //                          };
        self.reportDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSArray *)funArr
{
    return @[
             @"socketStatusRequest", //插座状态数据
             @"powerSwitchStatusRequest", //插座电源开关状态
             @"powerSwitchRequest", //插座电源开关控制
             @"commonPatternListDataRequest", //定时列表数据
             @"commonPatternNewTimingRequest", //普通模式新建定时
             @"commonPatternEditTimingRequest", //普通模式编辑定时
             @"commonPatternDeleteTimingRequest", //删除定时
             @"countdownDataRequest", //倒计时页面数据
             @"powerSwitchCountdownRequest", //设置电源开关倒计时
             @"temperatureAndHumidityDataRequest", //温湿度页面数据
             @"alarmTemperatureValueRequest", //设置告警温度值
             @"alarmHumidityValueRequest", //设置告警湿度值
             @"spendingCountdownDataRequest",//查询定量定费
             @"spendingCountdownAlarmRequest",//设置定量定费
             @"queryTemperatureUnitRequest",//查询温度单位
             ];
}

- (NSDictionary *)funDic
{
    return @{
             @"powerSwitchStatusRequest":@"powerSwitchStatusRequest:",//插座开关状态
             @"powerSwitchRequest":@"powerSwitchRequest:",//插座开关控制
             @"commonPatternListDataRequest":@"commonPatternListDataRequest:",//定时列表数据
             @"commonPatternNewTimingRequest":@"commonPatternNewTimingRequest:",//新建定时
             @"commonPatternEditTimingRequest":@"commonPatternEditTimingRequest:",//编辑定时
             @"commonPatternDeleteTimingRequest":@"commonPatternDeleteTimingRequest:",//删除定时
             @"countdownDataRequest":@"countdownDataRequest:",//倒计时页面数据
             @"powerSwitchCountdownRequest":@"powerSwitchCountdownRequest:",//开关倒计时
             @"temperatureAndHumidityDataRequest":@"temperatureAndHumidityDataRequest:",//查询定温湿度
             @"alarmTemperatureValueRequest":@"alarmTemperatureValueRequest:",//设置温度警告值
             @"alarmHumidityValueRequest":@"alarmHumidityValueRequest:",//设置湿度警告值
             @"spendingCountdownDataRequest":@"spendingCountdownDataRequest:",//查询定量定费
             @"spendingCountdownAlarmRequest":@"spendingCountdownAlarmRequest:",//设置定量定费
             @"queryTemperatureUnitRequest":@"queryTemperatureUnitRequest:",//查询温度单位
            };
}


#pragma mark 请求插座实时状态数据
- (void)socketStatusRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    BOOL recevie = [[object objectForKey:@"receive"] boolValue];
    if (recevie) {
        NSDictionary *dic =[[NSDictionary alloc] initWithDictionary:[self.reportDic objectForKey:mac]];
        NSString *json = [ToolHandle toJsonString:dic];
        NSString *jsCode = [[NSString alloc] initWithFormat:@"socketStatusResponse('%@','%@')",mac,json];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
    }
}

#pragma mark 上报插座实时状态数据
- (void)ReportingRealTimeData:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"上报温湿度功率数据........");
    NSMutableDictionary *muDic =[[NSMutableDictionary alloc] initWithDictionary:[self.reportDic objectForKey:deviceMac]];
    for (NSString *key in object.allKeys) {
        [muDic setObject:[object objectForKey:key] forKey:key];
    }
    [self.reportDic setValue:muDic forKey:deviceMac];
    NSString *json = [ToolHandle toJsonString:muDic];
    NSString *jsCode = [[NSString alloc] initWithFormat:@"socketStatusResponse('%@','%@')",deviceMac,json];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 查询温度单位
- (void)queryTemperatureUnitRequest:(NSDictionary *)object
{
    NSLog(@"queryTemperatureUnitRequest..........");
    uint8_t header = 0xff;
    uint8_t len_h = 0x00;
    uint8_t len_l = 0x04;
    uint8_t reserve_h = 0x00;
    uint8_t reserve_l = 0x00;
    uint8_t type= 0x01;
    uint8_t cmd = 0x1d;
    uint8_t ee = 0xee;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:header]];
    [data appendData:[self getData:len_h]];
    [data appendData:[self getData:len_l]];
    [data appendData:[self getData:reserve_h]];
    [data appendData:[self getData:reserve_l]];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    Byte *byte = (Byte*)[data bytes];
    Byte b = myCRC8(byte, 3, (int)data.length);
    [data appendData:[NSData dataWithBytes:&b length:sizeof(b)]];
    [data appendData:[self getData:ee]];
        NSString *mac = [object objectForKey:@"mac"];
    [self sendData:data mac:mac];;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self performSelector:@selector(queryTemperatureUnitRequest:) withObject:nil afterDelay:3];
    });
}

#pragma mark 查询温度单位返回
- (void)queryTemperatureUnitResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"queryTemperatureUnitResponse..........");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    NSInteger type = [[object objectForKey:@"type"] integerValue];
    NSString *jsonCode = [NSString stringWithFormat:@"queryTemperatureUnitResponse('%@',%d,%ld)",deviceMac,result,type];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 插座继电器状态请求
- (void)powerSwitchStatusRequest:(NSDictionary *)object
{
    NSLog(@"powerSwitchStatusRequest..........");
    int8_t header = 0xff;
    int8_t len_h = 0x00;
    int8_t len_l = 0x04;
    int8_t reserve_h = 0x00;
    int8_t reserve_l = 0x00;
    int8_t type= 0x02;
    int8_t cmd = 0x0b;
    int8_t ee = 0xee;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:header]];
    [data appendData:[self getData:len_h]];
    [data appendData:[self getData:len_l]];
    [data appendData:[self getData:reserve_h]];
    [data appendData:[self getData:reserve_l]];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    Byte *byte = (Byte*)[data bytes];
    Byte b = myCRC8(byte, 3, (int)data.length);
    [data appendData:[NSData dataWithBytes:&b length:sizeof(b)]];
    [data appendData:[self getData:ee]];
    NSString *mac = [object objectForKey:@"mac"];
    [self sendData:data mac:mac];;
}

#pragma mark 插座继电器控制
- (void)powerSwitchRequest:(NSDictionary *)object
{
    NSLog(@"powerSwitchRequest..........");
    BOOL state = [[object objectForKey:@"status"] boolValue];
    int8_t header = 0xff;
    int8_t len_h = 0x00;
    int8_t len_l = 0x06;
    int8_t reserve_h = 0x00;
    int8_t reserve_l = 0x00;
    int8_t type= 0x02;
    int8_t cmd = 0x01;
    int8_t mode = 0x01;
    int8_t relayswitch = (state == true)? 0x01:0x00;
    int8_t ee = 0xee;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:header]];
    [data appendData:[self getData:len_h]];
    [data appendData:[self getData:len_l]];
    [data appendData:[self getData:reserve_h]];
    [data appendData:[self getData:reserve_l]];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:mode]];
    [data appendData:[self getData:relayswitch]];
    Byte *byte = (Byte*)[data bytes];
    Byte b = myCRC8(byte, 3, (int)data.length);
    [data appendData:[NSData dataWithBytes:&b length:sizeof(b)]];
    [data appendData:[self getData:ee]];
    NSString *mac = [object objectForKey:@"mac"];
    [self sendData:data mac:mac];;
}

#pragma mark 继电器控制返回
- (void)powerSwitchResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"powerSwitchResponse..........");
    NSString *jsCode = [[NSString alloc] initWithFormat:@"powerSwitchResponse('%@',%d)",deviceMac,[[object objectForKey:@"state"] boolValue]];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 查询定时列表数据
- (void)commonPatternListDataRequest:(NSDictionary *)object
{
    NSLog(@"commonPatternListDataRequest..........");
    int8_t header = 0xff;
    int8_t len_h = 0x00;
    int8_t len_l = 0x05;
    int8_t reserve_h = 0x00;
    int8_t reserve_l = 0x00;
    int8_t type= 0x02;
    int8_t cmd = 0x13;
    int8_t ee = 0xee;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:header]];
    [data appendData:[self getData:len_h]];
    [data appendData:[self getData:len_l]];
    [data appendData:[self getData:reserve_h]];
    [data appendData:[self getData:reserve_l]];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:0x01]];
    Byte *byte = (Byte*)[data bytes];
    Byte b = myCRC8(byte, 3, (int)data.length);
    [data appendData:[NSData dataWithBytes:&b length:sizeof(b)]];
    [data appendData:[self getData:ee]];
    NSString *mac = [object objectForKey:@"mac"];
    [self sendData:data mac:mac];;
}

#pragma mark 定时列表数据返回
- (void)commonPatternListDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"commonPatternListDataResponse..........");
    NSData *data = [object objectForKey:@"data"];
    NSMutableData *timeData = [NSMutableData data];
    [timeData appendData:[data subdataWithRange:NSMakeRange(9, data.length-11)]];
    Byte *byte = (Byte *)[timeData bytes];
    NSMutableArray *arr = [NSMutableArray array];
    //    NSInteger model = byte[8];
    if (timeData.length>5 && timeData.length%6 == 0) {
        NSInteger length = timeData.length/6;
        for (NSInteger i= 0; i<length; i++) {
            NSInteger ID = byte[i*6];
            BOOL swit = (BOOL)byte[i*6+1];
            NSInteger week = byte[i*6+2];
            NSInteger hour = byte[i*6+3];
            NSInteger minute = byte[i*6+4];
            BOOL state = byte[i*6+5] == 0x01?true:false;
            NSString *time = [NSString stringWithFormat:@"%ld:%ld",hour,minute];
            NSDictionary *dic = @{
                                  @"switch":@(swit),
                                  @"time":time,
                                  @"id":@(ID),
                                  @"state":@(state),
                                  @"week":@(week),
                                  };
            [arr addObject:dic];
        }
    }
    NSString *json = [ToolHandle toJsonString:arr];
    NSString *json1 = [ToolHandle toJsonString:@[]];
    NSString *jsCode = [NSString stringWithFormat:@"commonPatternListDataResponse('%@','%@','%@')",deviceMac,json,json1];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    if (json.length<10) {
        NSLog(@"\n...........time...................%ld",data.length);
    }
}

#pragma mark 普通模式新建定时
- (void)commonPatternNewTimingRequest:(NSDictionary *)object
{
    int8_t mode = [[object objectForKey:@"mode"] integerValue];
    [self timingOperation:object mode:mode confirm:0x01];
}

#pragma mark 普通模式编辑定时
- (void)commonPatternEditTimingRequest:(NSDictionary *)object
{
    int8_t mode = [[object objectForKey:@"mode"] integerValue];
    [self timingOperation:object mode:mode confirm:0x01];
    NSLog(@"commonPatternEditTimingRequest..........");
}

#pragma mark 删除定时
- (void)commonPatternDeleteTimingRequest:(NSDictionary *)object
{
    int8_t mode = [[object objectForKey:@"mode"] integerValue];
    [self timingOperation:object mode:mode confirm:0x02];
    NSLog(@"commonPatternDeleteTimingRequest..........");
}

-  (void)timingOperation:(NSDictionary *)object mode:(int8_t)mode confirm:(int8_t)confirm
{
    if (mode == 0x02) {
        return;
    }
    NSString *time = [[object objectForKey:@"time"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray *times = [time componentsSeparatedByString:@":"];
    NSLog(@"commonPatternNewTimingRequest..........");
    NSInteger ids = [[object objectForKey:@"ID"] integerValue];
    int8_t header = 0xff;
    int8_t len_h = 0x00;
    int8_t len_l = 0x0C;
    int8_t reserve_h = 0x00;
    int8_t reserve_l = 0x00;
    int8_t type= 0x02;
    int8_t cmd = 0x05;
    //    int8_t mode = 0x01;//0x01普通 0x02 进阶
    int8_t ID = (int8_t)(ids==0?0xff:ids);//定时唯一标识
    //    int8_t state = [[object objectForKey:@"state"] boolValue] == true? 0x01:0x02;//0x01保存 0x02删除
    int8_t switc = [[object objectForKey:@"switchtab"] boolValue] ? 0x01 : 0x00;//开启关闭
    int8_t weak= (int8_t)[[object objectForKey:@"week"] intValue];
    int8_t hour = (int8_t)[[times firstObject] intValue];
    int8_t minute = (int8_t)[[times lastObject] intValue];
    int8_t confirma  = [[object objectForKey:@"state"] boolValue] == true? 0x01:0x02;
    int8_t ee = 0xee;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:header]];
    [data appendData:[self getData:len_h]];
    [data appendData:[self getData:len_l]];
    [data appendData:[self getData:reserve_h]];
    [data appendData:[self getData:reserve_l]];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:mode]];
    [data appendData:[self getData:ID]];
    [data appendData:[self getData:confirm]];
    [data appendData:[self getData:switc]];
    [data appendData:[self getData:weak]];
    [data appendData:[self getData:hour]];
    [data appendData:[self getData:minute]];
    [data appendData:[self getData:confirma]];
    Byte *byte = (Byte*)[data bytes];
    Byte b = myCRC8(byte, 3, (int)data.length);
    [data appendData:[NSData dataWithBytes:&b length:sizeof(b)]];
    [data appendData:[self getData:ee]];
    NSString *mac = [object objectForKey:@"mac"];
    [self sendData:data mac:mac];;
}

#pragma mark 新建/编辑/删除定时操作返回
- (void)commonPatternTimingResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    BOOL state = [[object objectForKey:@"result"] boolValue];
    NSString *jsCode = [NSString stringWithFormat:@"commonPatternTimingResponse('%@',%d)",deviceMac,state];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 上报定时结束
- (void)reportendoftime:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    [self powerSwitchStatusRequest:@{}];
    [self commonPatternListDataRequest:@{}];
    NSLog(@"powerSwitchResponse..........");
    NSString *jsCode = [[NSString alloc] initWithFormat:@"powerSwitchResponse('%@',%d)",deviceMac,[[object objectForKey:@"state"] boolValue]];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 倒计时页面数据
- (void)countdownDataRequest:(NSDictionary *)object
{
    NSLog(@"countdownDataRequest..........");
    int8_t header = 0xff;
    int8_t len_h = 0x00;
    int8_t len_l = 0x04;
    int8_t reserve_h = 0x00;
    int8_t reserve_l = 0x00;
    int8_t type= 0x02;
    int8_t cmd = 0x0d;
    int8_t ee = 0xee;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:header]];
    [data appendData:[self getData:len_h]];
    [data appendData:[self getData:len_l]];
    [data appendData:[self getData:reserve_h]];
    [data appendData:[self getData:reserve_l]];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    Byte *byte = (Byte*)[data bytes];
    Byte b = myCRC8(byte, 3, (int)data.length);
    [data appendData:[NSData dataWithBytes:&b length:sizeof(b)]];
    [data appendData:[self getData:ee]];
    NSString *mac = [object objectForKey:@"mac"];
    [self sendData:data mac:mac];;
}

#pragma mark 倒计时页面数据返回
- (void)CountdownResult:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"countdownDataResponse..........");
    BOOL state = [object[@"state"] integerValue] == 1?true :false;
    BOOL switc = [object[@"switch"] integerValue] == 1? true :false;
    NSInteger hour = [object[@"hour"] integerValue];
    NSInteger mintute = [object[@"minute"] integerValue];
    NSDictionary *dic = @{
                          @"hour":@(hour),
                          @"minute":@(mintute),
                          @"Switchgear":@(switc),//开关机
                          @"countdownSwitch":@(state),//启动结束
                          @"allTime":@(hour*60+mintute),
                          };
    NSString *json = [ToolHandle toJsonString:dic];
    NSString *jsonCode = [NSString stringWithFormat:@"countdownDataResponse('%@','%@')",deviceMac,json];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
    NSMutableDictionary *muDic =[[NSMutableDictionary alloc] initWithDictionary:[self.reportDic objectForKey:deviceMac]];
    [muDic setObject:@((hour*60+mintute)*60*1000) forKey:@"time"];
    [self.reportDic setValue:muDic forKey:deviceMac];
    NSString *json1 = [ToolHandle toJsonString:muDic];
    NSString *jsCode1 = [[NSString alloc] initWithFormat:@"socketStatusResponse('%@','%@')",deviceMac,json1];
    [self.web evaluateJavaScript:jsCode1 completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 设置电源开关倒计时
- (void)powerSwitchCountdownRequest:(NSDictionary *)object
{
    NSLog(@"powerSwitchCountdownRequest..........");
    BOOL state = [[object objectForKey:@"state"] boolValue];    //启动结束
    BOOL swit = [[object objectForKey:@"Switchgear"] boolValue]; //开机关机
    int8_t header = 0xff;
    int8_t len_h = 0x00;
    int8_t len_l = 0x08;
    int8_t reserve_h = 0x00;
    int8_t reserve_l = 0x00;
    int8_t type= 0x02;
    int8_t cmd = 0x07;
    int8_t confirm = (state == true)? 0x01:0x02;
    int8_t switchs = (swit == true)? 0x01:0x00;
    int8_t hour = (int8_t)[[object objectForKey:@"hour"] integerValue];
    int8_t minute = (int8_t)[[object objectForKey:@"minute"] integerValue];
    int8_t ee = 0xee;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:header]];
    [data appendData:[self getData:len_h]];
    [data appendData:[self getData:len_l]];
    [data appendData:[self getData:reserve_h]];
    [data appendData:[self getData:reserve_l]];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:confirm]];
    [data appendData:[self getData:switchs]];
    [data appendData:[self getData:hour]];
    [data appendData:[self getData:minute]];
    Byte *byte = (Byte*)[data bytes];
    Byte b = myCRC8(byte, 3, (int)data.length);
    [data appendData:[NSData dataWithBytes:&b length:sizeof(b)]];
    [data appendData:[self getData:ee]];
    NSString *mac = [object objectForKey:@"mac"];
    [self sendData:data mac:mac];;
    
    [self countdownDataRequest:nil];
}

#pragma mark  设置电源开关倒计时返回
- (void)powerSwitchCountdownResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"powerSwitchCountdownResponse..........");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    BOOL state = [[object objectForKey:@"state"] boolValue];
    BOOL switc = [[object objectForKey:@"switch"] boolValue];
    NSString *jsCode = [NSString stringWithFormat:@"powerSwitchCountdownResponse('%@',%d,%d)",deviceMac,state,result];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
    if (state == false) {
        NSDictionary *dic = @{
                              @"hour":@(0),
                              @"minute":@(0),
                              @"Switchgear":@(switc),//开关机
                              @"countdownSwitch":@(false),//启动结束
                              @"allTime":@(0),
                              };
        NSString *json = [ToolHandle toJsonString:dic];
        NSString *jsonCode = [NSString stringWithFormat:@"countdownDataResponse('%@','%@')",deviceMac,json];
        [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
    }
    
}

#pragma mark 查询定温湿度值
- (void)temperatureAndHumidityDataRequest:(NSDictionary *)object
{
    NSLog(@"temperatureAndHumidityDataRequest..........");
    [self queryTemperatureValueAndHumidityValue:0x01 object:object];
    [self queryTemperatureValueAndHumidityValue:0x02 object:object];
}

- (void)queryTemperatureValueAndHumidityValue:(int8_t)switchs object:(NSDictionary *)object
{
    NSLog(@"queryTemperatureValueAndHumidityValue..........");
    int8_t header = 0xff;
    int8_t len_h = 0x00;
    int8_t len_l = 0x06;
    int8_t reserve_h = 0x00;
    int8_t reserve_l = 0x00;
    int8_t type= 0x02;
    int8_t cmd = 0x11;
    int8_t ee = 0xee;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:header]];
    [data appendData:[self getData:len_h]];
    [data appendData:[self getData:len_l]];
    [data appendData:[self getData:reserve_h]];
    [data appendData:[self getData:reserve_l]];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:0x01]];
    [data appendData:[self getData:switchs]];
    Byte *byte = (Byte*)[data bytes];
    Byte b = myCRC8(byte, 3, (int)data.length);
    [data appendData:[NSData dataWithBytes:&b length:sizeof(b)]];
    [data appendData:[self getData:ee]];
    NSString *mac = [object objectForKey:@"mac"];
    [self sendData:data mac:mac];;
}

#pragma mark 查询定温湿度结果回调
- (void)temperatureAndHumidityDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"temperatureAndHumidityDataResponse..........");
    NSInteger model = [[object objectForKey:@"mode"] integerValue];
    NSInteger type = [[object objectForKey:@"type"] integerValue];
    if (model == 1) {
        NSMutableDictionary *temp;
        if (self.temperAndHumiDic.allKeys.count) {
            temp  = [NSMutableDictionary dictionaryWithDictionary:[self.temperAndHumiDic objectForKey:@"temperature"] ];
        }else{
            temp = [[NSMutableDictionary alloc] init];
        }
        if (type == 1) {
            [temp setObject:object[@"currentValue"] forKey:@"currentValue"];
            [temp setObject:@([object[@"alarmValue"] integerValue]) forKey:@"hotAlarmValue"];
            [temp setObject:@([object[@"state"] boolValue]) forKey:@"hotAlarmSwitch"];
            
        }else{
            [temp setObject:object[@"currentValue"] forKey:@"currentValue"];
            [temp setObject:@([object[@"alarmValue"] integerValue]) forKey:@"codeAlarmValue"];
            [temp setObject:@([object[@"state"] boolValue]) forKey:@"codeAlarmSwitch"];
        }
        [self.temperAndHumiDic setObject:temp forKey:@"temperature"];
        
    }else{
        [self.temperAndHumiDic setObject:@{
                                           @"currentValue":object[@"currentValue"],
                                           @"alarmValue":object[@"alarmValue"],
                                           @"alarmSwitch":@([object[@"state"]boolValue]),
                                           } forKey:@"humidity"];
    }
    NSString *json = [ToolHandle toJsonString:self.temperAndHumiDic];
    NSString *jsonCode = [NSString stringWithFormat:@"temperatureAndHumidityDataResponse('%@','%@')",deviceMac,json];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
    NSLog(@"查询定温度返回结果。。。。。。。。。。。。。。。。。。。。%@",json);
}

#pragma mark 设置告警温度值
- (void)alarmTemperatureValueRequest:(NSDictionary *)object
{
    NSLog(@"alarmTemperatureValueRequest..........");
    [self alarmHumidityAndTemperatureValueRequest:object mode:0x01];
}
#pragma mark 设置告警湿度值
- (void)alarmHumidityValueRequest:(NSDictionary *)object
{
    NSLog(@"alarmHumidityValueRequest..........");
    //    [self alarmHumidityAndTemperatureValueRequest:object mode:0x02];
}

- (void)alarmHumidityAndTemperatureValueRequest:(NSDictionary *)object mode:(int8_t)mode
{
    NSLog(@"alarmHumidityAndTemperatureValueRequest..........");
    BOOL state = [[object objectForKey:@"state"] boolValue];
    
    NSInteger temp = [[object objectForKey:@"alarmValue"] floatValue]*100;
    int8_t header = 0xff;
    int8_t len_h = 0x00;
    int8_t len_l = 0x09;
    int8_t reserve_h = 0x00;
    int8_t reserve_l = 0x00;
    int8_t type = 0x02;
    int8_t cmd = 0x09;
    int8_t confirm = (state == true)? 0x01:0x02;
    int8_t switc = (int8_t)[[object objectForKey:@"mode"] integerValue];//0x01 0x02(上下限)
    int8_t temp_int = (int8_t)(temp/100);
    int8_t temp_deci = (int8_t)(temp%100);
    int8_t ee = 0xee;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:header]];
    [data appendData:[self getData:len_h]];
    [data appendData:[self getData:len_l]];
    [data appendData:[self getData:reserve_h]];
    [data appendData:[self getData:reserve_l]];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:confirm]];
    [data appendData:[self getData:mode]];
    [data appendData:[self getData:switc]];
    [data appendData:[self getData:temp_int]];
    [data appendData:[self getData:temp_deci]];
    Byte *byte = (Byte*)[data bytes];
    Byte b = myCRC8(byte, 3, (int)data.length);
    [data appendData:[NSData dataWithBytes:&b length:sizeof(b)]];
    [data appendData:[self getData:ee]];
    NSString *mac = [object objectForKey:@"mac"];
    [self sendData:data mac:mac];;
}

#pragma mark 设置告警温度值返回
#pragma mark 设置告警湿度值返回
- (void)alarmHumidityAndTemperatureValue:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"alarmHumidityAndTemperatureValue..........");
    NSInteger type = [[object objectForKey:@"type"] integerValue];
    NSInteger mode = [[object objectForKey:@"mode"] integerValue];
    BOOL result = [[object objectForKey:@"result"] boolValue];
    BOOL state = ([[object objectForKey:@"state"] integerValue] == 1)?true:false;
    NSString *jsCode;
    if (mode == 1) {
        //温度
        jsCode = [NSString stringWithFormat:@"alarmTemperatureValueResponse('%@',%d,%d,%d)",deviceMac,state,type,result];
    }else if (type == 2){
        //湿度
        jsCode = [NSString stringWithFormat:@"alarmHumidityValueResponse('%@',%d,%d)",deviceMac,state,result];
    }
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    if (type == 1) {
        [self queryTemperatureValueAndHumidityValue:0x01 object:@{@"mac":deviceMac}];
    }else if(type == 2){
        [self queryTemperatureValueAndHumidityValue:0x02 object:@{@"mac":deviceMac}];
    }
//    [self temperatureAndHumidityDataRequest:@{@"mac":deviceMac}];
}

#pragma mark 定量定费查询
- (void)spendingCountdownDataRequest:(NSDictionary *)object
{
    [self spendingCountdownDataRequest:object model:0x01];
    [self spendingCountdownDataRequest:object model:0x02];
}
- (void)spendingCountdownDataRequest:(NSDictionary *)object model:(int8_t)mode
{
    int8_t header = 0xff;
    int8_t len_h = 0x00;
    int8_t len_l = 0x05;
    int8_t reserve_h = 0x00;
    int8_t reserve_l = 0x00;
    int8_t type= 0x02;
    int8_t cmd = 0x17;
    int8_t ee = 0xee;
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:header]];
    [data appendData:[self getData:len_h]];
    [data appendData:[self getData:len_l]];
    [data appendData:[self getData:reserve_h]];
    [data appendData:[self getData:reserve_l]];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:mode]];
    Byte *byte = (Byte*)[data bytes];
    Byte b = myCRC8(byte, 3, (int)data.length);
    [data appendData:[NSData dataWithBytes:&b length:sizeof(b)]];
    [data appendData:[self getData:ee]];
    NSString *mac = [object objectForKey:@"mac"];
    [self sendData:data mac:mac];;
}

#pragma mark 查询定量定费返回
- (void)spendingCountdownDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    Byte *byte = (Byte *)[[object objectForKey:@"data"] bytes];
    BOOL result = !byte[7];
    BOOL confirm = byte[8] == 0x01 ? true : false;
    NSInteger mode = (NSInteger)byte[9];
    NSInteger year = byte[10] + 2000;
    NSInteger month = byte[11];
    NSInteger day = byte[12];
    NSInteger jing = (byte[13]<<8)+byte[14];
    NSInteger use = (byte[15]<<8)+byte[16];
    NSInteger price = (byte[17]<<8)+byte[18];
    NSDictionary *dic = @{
                          @"currentValue": @(use),
                          @"alarmValue": @(jing),
                          @"alarmSwitch": @(confirm),
                          @"year": @(year),
                          @"month": @(month),
                          @"day": @(day),
                          //        @"price":@(price),
                          };
    if (mode == 1) {
        [self.powerAndCostDic setObject:dic forKey:@"power"];
    }else{
        [self.powerAndCostDic setObject:dic forKey:@"cost"];
    }
    NSString *json = [ToolHandle toJsonString:self.powerAndCostDic];
    NSString *jsonCode = [NSString stringWithFormat:@"spendingCountdownDataResponse('%@',%d,'%@')",deviceMac,result,json];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 设置定量定费
- (void)spendingCountdownAlarmRequest:(NSDictionary *)object
{
    uint16_t alarm = [[object objectForKey:@"alarmValue"]integerValue];
    int8_t header = 0xff;
    int8_t len_h = 0x00;
    int8_t len_l = 0x0b;
    int8_t reserve_h = 0x00;
    int8_t reserve_l = 0x00;
    int8_t type= 0x02;
    int8_t cmd = 0x15;
    int8_t confirm = [[object objectForKey:@"alarmSwitch"]boolValue] == true? 0x01:0x02;
    int8_t mode = (int8_t)[[object objectForKey:@"mode"]integerValue];
    int8_t year = (int8_t)([[object objectForKey:@"year"]integerValue] - 2000);
    int8_t month = (int8_t)[[object objectForKey:@"month"]integerValue];
    int8_t day = (int8_t)[[object objectForKey:@"day"]integerValue];
    int8_t jing = (int8_t)(alarm>>8);
    int8_t jing1 = alarm;
    int8_t ee = 0xee;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:header]];
    [data appendData:[self getData:len_h]];
    [data appendData:[self getData:len_l]];
    [data appendData:[self getData:reserve_h]];
    [data appendData:[self getData:reserve_l]];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:confirm]];
    [data appendData:[self getData:mode]];
    [data appendData:[self getData:year]];
    [data appendData:[self getData:month]];
    [data appendData:[self getData:day]];
    [data appendData:[self getData:jing]];
    [data appendData:[self getData:jing1]];
    Byte *byte = (Byte*)[data bytes];
    Byte b = myCRC8(byte, 3, (int)data.length);
    [data appendData:[NSData dataWithBytes:&b length:sizeof(b)]];
    [data appendData:[self getData:ee]];
    NSString *mac = [object objectForKey:@"mac"];
    [self sendData:data mac:mac];;
}

#pragma mark 查询定量定费返回
-(void)spendingCountdownAlarmResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    BOOL result = [[object objectForKey:@"result"]boolValue];
    BOOL state = [[object objectForKey:@"state"]integerValue] == 1?true:false;
    NSInteger mode = [[object objectForKey:@"mode"]integerValue];
    NSString *jsonCode = [NSString stringWithFormat:@"spendingCountdownAlarmResponse('%@',%ld,%d,%d)",deviceMac,mode,state,result];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
}

- (void)sendData:(NSMutableData *)data mac:(NSString *)mac
{
    [[BluetoothManager shareInstance] sendData:data];
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
        SEL sel = NSSelectorFromString(self.funDic[message.name]);
        if ([self respondsToSelector:sel]) {
            [[HandlingDataModel shareInstance] regeistDelegate:self];
            [self performSelector:sel withObject:message.body];
        }
    }
}

@end
