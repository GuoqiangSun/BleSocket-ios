//
//  SettingModel.m
//  BluetoothSocket
//
//  Created by Mac on 2018/6/7.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "SettingModel.h"

@interface SettingModel ()<WKScriptMessageHandler>



@end

@implementation SettingModel

- (instancetype)init
{
    if (self = [super init]) {
       
    }
    return self;
}

- (NSArray *)funArr
{
    return @[
             @"reNameRequest",  //设备重命名
             @"settingAlarmVoltageRequest", //设置电压告警值
             @"queryAlarmVoltageRequest", //查询电压告警值
             @"settingAlarmCurrentRequest",//设置电流告警值
             @"queryAlarmCurrentRequest",//查询电流告警值
             @"settingAlarmPowerRequest",//设置功率告警值
             @"queryAlarmPowerRequest",//查询功率告警值
             @"settingTemperatureUnitRequest",//设置温度单位
//             @"queryTemperatureUnitRequest",//查询温度单位
             @"settingMonetarytUnitRequest",//设置货币单位
             @"queryMonetarytUnitRequest",//查询货币单位
             @"settingLocalElectricityRequest",//设置本地电价
             @"queryLocalElectricityRequest",//查询本地电价
             @"settingResumeSetupRequest",//恢复出厂设置
             @"BackupTimeAndDirectoryRequest",//备份时间目录查询
             @"BackupDataRequest",//备份数据到手机
             @"BackupRecoveryDataRequest",//备份中恢复数据
             
             ];
}

- (NSDictionary *)funDic
{
    return @{
             @"reNameRequest":@"reNameRequest:", //重命名
             @"settingAlarmVoltageRequest":@"settingAlarmVoltageRequest:", //设置电压告警值
             @"queryAlarmVoltageRequest":@"queryAlarmVoltageRequest:", //查询电压告警值
             @"settingAlarmCurrentRequest":@"settingAlarmCurrentRequest:",//设置电流告警值
             @"queryAlarmCurrentRequest":@"queryAlarmCurrentRequest:",//查询电流告警值
             @"settingAlarmPowerRequest":@"settingAlarmPowerRequest:",//设置功率告警值
             @"queryAlarmPowerRequest":@"queryAlarmPowerRequest:",//查询功率告警值
             @"settingTemperatureUnitRequest":@"settingTemperatureUnitRequest:",//设置温度单位
//             @"queryTemperatureUnitRequest":@"queryTemperatureUnitRequest:",//查询温度单位
             @"settingMonetarytUnitRequest":@"settingMonetarytUnitRequest:",//设置货币单位
             @"queryMonetarytUnitRequest":@"queryMonetarytUnitRequest:",//查询货币单位
             @"settingLocalElectricityRequest":@"settingLocalElectricityRequest:",//设置本地电价
             @"queryLocalElectricityRequest":@"queryLocalElectricityRequest:",//查询本地电价
             @"settingResumeSetupRequest":@"settingResumeSetupRequest:",//恢复出厂设置
             @"BackupTimeAndDirectoryRequest":@"BackupTimeAndDirectoryRequest:",//备份时间目录查询
             @"BackupDataRequest":@"BackupDataRequest:",//备份数据到手机
             @"BackupRecoveryDataRequest":@"BackupRecoveryDataRequest:",//备份中恢复数据
            };
}

#pragma mark 设置界面数据
#pragma mark 重命名设备名称
- (void)reNameRequest:(NSDictionary *)object
{
    NSLog(@"reNameRequest..........");
    uint8_t header = 0xff;
    uint8_t len_h = 0x00;
    uint8_t len_l = 0x04+[[object objectForKey:@"newname"] dataUsingEncoding:NSUTF8StringEncoding].length;
    uint8_t reserve_h = 0x00;
    uint8_t reserve_l = 0x00;
    uint8_t type= 0x01;
    uint8_t cmd = 0x0b;
    uint8_t ee = 0xee;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:header]];
    [data appendData:[self getData:len_h]];
    [data appendData:[self getData:len_l]];
    [data appendData:[self getData:reserve_h]];
    [data appendData:[self getData:reserve_l]];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[[object objectForKey:@"newname"] dataUsingEncoding:NSUTF8StringEncoding]];
    Byte *byte = (Byte*)[data bytes];
    Byte b = myCRC8(byte, 3, (int)data.length);
    [data appendData:[NSData dataWithBytes:&b length:sizeof(b)]];
    [data appendData:[self getData:ee]];
    NSString *mac = [object objectForKey:@"mac"];
    [self sendData:data mac:mac];;
}

- (void)reNameResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"reNameResponse..........");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    NSString *jsonCode = [NSString stringWithFormat:@"reNameResponse('%@',%d)",deviceMac,result];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}


#pragma mark 设置电压告警值
- (void)settingAlarmVoltageRequest:(NSDictionary *)object
{
    NSLog(@"settingAlarmVoltageRequest..........");
    uint16_t voltage = (uint16_t)[[object objectForKey:@"voltage"] integerValue];
    uint8_t header = 0xff;
    uint8_t len_h = 0x00;
    uint8_t len_l = 0x06;
    uint8_t reserve_h = 0x00;
    uint8_t reserve_l = 0x00;
    uint8_t type= 0x01;
    uint8_t cmd = 0x0f;
    uint8_t big = voltage>>8;
    uint8_t small = voltage;
    uint8_t ee = 0xee;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:header]];
    [data appendData:[self getData:len_h]];
    [data appendData:[self getData:len_l]];
    [data appendData:[self getData:reserve_h]];
    [data appendData:[self getData:reserve_l]];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:big]];
    [data appendData:[self getData:small]];
    Byte *byte = (Byte*)[data bytes];
    Byte b = myCRC8(byte, 3, (int)data.length);
    [data appendData:[NSData dataWithBytes:&b length:sizeof(b)]];
    [data appendData:[self getData:ee]];
    NSString *mac = [object objectForKey:@"mac"];
    [self sendData:data mac:mac];;
}

#pragma mark 设置电压警告值返回
- (void)settingAlarmVoltageResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"settingAlarmVoltageResponse..........");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    NSString *jsonCode = [NSString stringWithFormat:@"settingAlarmVoltageResponse('%@',%d)",deviceMac,result];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 查询电压告警值
- (void)queryAlarmVoltageRequest:(NSDictionary *)object
{
    NSLog(@"queryAlarmVoltageRequest..........");
    uint8_t header = 0xff;
    uint8_t len_h = 0x00;
    uint8_t len_l = 0x04;
    uint8_t reserve_h = 0x00;
    uint8_t reserve_l = 0x00;
    uint8_t type= 0x01;
    uint8_t cmd = 0x11;
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
}

#pragma mark 查询电压警告值返回
- (void)queryAlarmVoltageResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"queryAlarmVoltageResponse..........");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    CGFloat Voltage = [[object objectForKey:@"Voltage"] floatValue];
    NSString *jsonCode = [NSString stringWithFormat:@"queryAlarmVoltageResponse('%@',%d,%.2f)",deviceMac,result,Voltage];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 设置电流警告值
- (void)settingAlarmCurrentRequest:(NSDictionary *)object
{
    NSLog(@"settingAlarmCurrentRequest..........");
    uint8_t current = (uint8_t)[[object objectForKey:@"current"] integerValue];
    uint8_t header = 0xff;
    uint8_t len_h = 0x00;
    uint8_t len_l = 0x05;
    uint8_t reserve_h = 0x00;
    uint8_t reserve_l = 0x00;
    uint8_t type= 0x01;
    uint8_t cmd = 0x13;
    uint8_t ee = 0xee;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:header]];
    [data appendData:[self getData:len_h]];
    [data appendData:[self getData:len_l]];
    [data appendData:[self getData:reserve_h]];
    [data appendData:[self getData:reserve_l]];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:current]];
    Byte *byte = (Byte*)[data bytes];
    Byte b = myCRC8(byte, 3, (int)data.length);
    [data appendData:[NSData dataWithBytes:&b length:sizeof(b)]];
    [data appendData:[self getData:ee]];
    NSString *mac = [object objectForKey:@"mac"];
    [self sendData:data mac:mac];;
}

#pragma mark 设置电流警告值返回
-(void)settingAlarmCurrentResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"settingAlarmCurrentResponse..........");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    NSString *jsonCode = [NSString stringWithFormat:@"settingAlarmCurrentResponse('%@',%d)",deviceMac,result];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 查询电流警告值
- (void)queryAlarmCurrentRequest:(NSDictionary *)object
{
    NSLog(@"queryAlarmCurrentRequest..........");
    uint8_t header = 0xff;
    uint8_t len_h = 0x00;
    uint8_t len_l = 0x04;
    uint8_t reserve_h = 0x00;
    uint8_t reserve_l = 0x00;
    uint8_t type= 0x01;
    uint8_t cmd = 0x15;
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
}

#pragma mark 查询电流警告值返回
- (void)queryAlarmCurrentResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"queryAlarmCurrentResponse..........");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    CGFloat electricity = [[object objectForKey:@"electricity"] floatValue];
    NSString *jsonCode = [NSString stringWithFormat:@"queryAlarmCurrentResponse('%@',%d,%.2f)",deviceMac,result,electricity];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 设置功率告警值
- (void)settingAlarmPowerRequest:(NSDictionary *)object
{
    NSLog(@"settingAlarmPowerRequest..........");
    uint16_t power = (uint16_t)[[object objectForKey:@"power"] integerValue];
    uint8_t header = 0xff;
    uint8_t len_h = 0x00;
    uint8_t len_l = 0x06;
    uint8_t reserve_h = 0x00;
    uint8_t reserve_l = 0x00;
    uint8_t type= 0x01;
    uint8_t cmd = 0x17;
    uint8_t big = power>>8;
    uint8_t small = power;
    uint8_t ee = 0xee;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:header]];
    [data appendData:[self getData:len_h]];
    [data appendData:[self getData:len_l]];
    [data appendData:[self getData:reserve_h]];
    [data appendData:[self getData:reserve_l]];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:big]];
    [data appendData:[self getData:small]];
    Byte *byte = (Byte*)[data bytes];
    Byte b = myCRC8(byte, 3, (int)data.length);
    [data appendData:[NSData dataWithBytes:&b length:sizeof(b)]];
    [data appendData:[self getData:ee]];
    NSString *mac = [object objectForKey:@"mac"];
    [self sendData:data mac:mac];;
}

#pragma mark 设置功率告警值返回
- (void)settingAlarmPowerResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"settingAlarmPowerResponse..........");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    NSString *jsonCode = [NSString stringWithFormat:@"settingAlarmPowerResponse('%@',%d)",deviceMac,result];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 查询功率告警值
- (void)queryAlarmPowerRequest:(NSDictionary *)object
{
    NSLog(@"queryAlarmPowerRequest..........");
    uint8_t header = 0xff;
    uint8_t len_h = 0x00;
    uint8_t len_l = 0x04;
    uint8_t reserve_h = 0x00;
    uint8_t reserve_l = 0x00;
    uint8_t type= 0x01;
    uint8_t cmd = 0x19;
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
}

#pragma mark 查询功率告警值返回
- (void)queryAlarmPowerResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"queryAlarmPowerResponse..........");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    CGFloat power = [[object objectForKey:@"power"] floatValue];
    NSString *jsonCode = [NSString stringWithFormat:@"queryAlarmPowerResponse('%@',%d,%.2f)",deviceMac,result,power];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 设置温度单位
- (void)settingTemperatureUnitRequest:(NSDictionary *)object
{
    NSLog(@"settingTemperatureUnitRequest..........");
    uint8_t meter = (uint8_t)[[object objectForKey:@"type"] integerValue];
    uint8_t header = 0xff;
    uint8_t len_h = 0x00;
    uint8_t len_l = 0x05;
    uint8_t reserve_h = 0x00;
    uint8_t reserve_l = 0x00;
    uint8_t type= 0x01;
    uint8_t cmd = 0x1b;
    uint8_t ee = 0xee;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:header]];
    [data appendData:[self getData:len_h]];
    [data appendData:[self getData:len_l]];
    [data appendData:[self getData:reserve_h]];
    [data appendData:[self getData:reserve_l]];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:meter]];
    Byte *byte = (Byte*)[data bytes];
    Byte b = myCRC8(byte, 3, (int)data.length);
    [data appendData:[NSData dataWithBytes:&b length:sizeof(b)]];
    [data appendData:[self getData:ee]];
    NSString *mac = [object objectForKey:@"mac"];
    [self sendData:data mac:mac];;
}

#pragma mark 设置温度单位返回
-(void)settingTemperatureUnitResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"settingTemperatureUnitResponse..........");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    NSString *jsonCode = [NSString stringWithFormat:@"settingTemperatureUnitResponse('%@',%d)",deviceMac,result];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 设置货币单位
- (void)settingMonetarytUnitRequest:(NSDictionary *)object
{
    NSLog(@"settingMonetarytUnitRequest..........");
    uint8_t meter = (uint8_t)[[object objectForKey:@"type"] integerValue];
    uint8_t header = 0xff;
    uint8_t len_h = 0x00;
    uint8_t len_l = 0x05;
    uint8_t reserve_h = 0x00;
    uint8_t reserve_l = 0x00;
    uint8_t type= 0x01;
    uint8_t cmd = 0x1f;
    uint8_t ee = 0xee;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:header]];
    [data appendData:[self getData:len_h]];
    [data appendData:[self getData:len_l]];
    [data appendData:[self getData:reserve_h]];
    [data appendData:[self getData:reserve_l]];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:meter]];
    Byte *byte = (Byte*)[data bytes];
    Byte b = myCRC8(byte, 3, (int)data.length);
    [data appendData:[NSData dataWithBytes:&b length:sizeof(b)]];
    [data appendData:[self getData:ee]];
    NSString *mac = [object objectForKey:@"mac"];
    [self sendData:data mac:mac];;
}

#pragma mark 设置货币单位返回
- (void)settingMonetarytUnitResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac{
    NSLog(@"settingMonetarytUnitResponse..........");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    NSString *jsonCode = [NSString stringWithFormat:@"settingMonetarytUnitResponse('%@',%d)",deviceMac,result];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 查询货币单位
- (void)queryMonetarytUnitRequest:(NSDictionary *)object
{
    NSLog(@"queryMonetarytUnitRequest..........");
    uint8_t header = 0xff;
    uint8_t len_h = 0x00;
    uint8_t len_l = 0x04;
    uint8_t reserve_h = 0x00;
    uint8_t reserve_l = 0x00;
    uint8_t type= 0x01;
    uint8_t cmd = 0x21;
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
}

#pragma mark 查询货币单位返回
- (void)queryMonetarytUnitResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"queryMonetarytUnitResponse..........");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    NSInteger type = [[object objectForKey:@"type"] integerValue];
    NSString *jsonCode = [NSString stringWithFormat:@"queryMonetarytUnitResponse('%@',%d,%ld)",deviceMac,result,type];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 设置本地电价
- (void)settingLocalElectricityRequest:(NSDictionary *)object
{
    NSLog(@"settingLocalElectricityRequest..........");
    uint16_t price = [[object objectForKey:@"num"]integerValue];
    uint8_t header = 0xff;
    uint8_t len_h = 0x00;
    uint8_t len_l = 0x06;
    uint8_t reserve_h = 0x00;
    uint8_t reserve_l = 0x00;
    uint8_t type= 0x01;
    uint8_t cmd = 0x23;
    uint8_t big = (uint8_t)(price>>8);
    uint8_t small = (uint8_t)price;
    uint8_t ee = 0xee;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:header]];
    [data appendData:[self getData:len_h]];
    [data appendData:[self getData:len_l]];
    [data appendData:[self getData:reserve_h]];
    [data appendData:[self getData:reserve_l]];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:big]];
    [data appendData:[self getData:small]];
    Byte *byte = (Byte*)[data bytes];
    Byte b = myCRC8(byte, 3, (int)data.length);
    [data appendData:[NSData dataWithBytes:&b length:sizeof(b)]];
    [data appendData:[self getData:ee]];
     NSString *mac = [object objectForKey:@"mac"];
    [self sendData:data mac:mac];;
}

#pragma mark 设置本地电价返回
- (void)settingLocalElectricityResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac{
    NSLog(@"settingLocalElectricityResponse..........");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    NSString *jsonCode = [NSString stringWithFormat:@"settingLocalElectricityResponse('%@',%d)",deviceMac,result];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 查询本地电价
- (void)queryLocalElectricityRequest:(NSDictionary *)object
{
    NSLog(@"queryLocalElectricityRequest..........");
    uint8_t header = 0xff;
    uint8_t len_h = 0x00;
    uint8_t len_l = 0x04;
    uint8_t reserve_h = 0x00;
    uint8_t reserve_l = 0x00;
    uint8_t type= 0x01;
    uint8_t cmd = 0x25;
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
}

#pragma mark 查询本地电价返回
- (void)queryLocalElectricityResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"queryLocalElectricityResponse..........");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    CGFloat price = [[object objectForKey:@"price"] floatValue];
    NSString *jsonCode = [NSString stringWithFormat:@"queryLocalElectricityResponse('%@',%d,%.2f)",deviceMac,result,price];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 恢复出厂设置
- (void)settingResumeSetupRequest:(NSDictionary *)object
{
    NSLog(@"settingResumeSetupRequest..........");
    uint8_t header = 0xff;
    uint8_t len_h = 0x00;
    uint8_t len_l = 0x04;
    uint8_t reserve_h = 0x00;
    uint8_t reserve_l = 0x00;
    uint8_t type= 0x01;
    uint8_t cmd = 0x27;
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
}

#pragma mark 恢复出厂设置返回
- (void)settingResumeSetupResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"settingResumeSetupResponse..........");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    NSString *jsonCode = [NSString stringWithFormat:@"settingResumeSetupResponse('%@',%d)",deviceMac,result];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 获取备份路径
- (void)BackupTimeAndDirectoryRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    NSString *docu = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
     NSString *root = [docu stringByAppendingPathComponent:mac];
    NSString *floder = [root stringByAppendingPathComponent:@"cacheData.txt"];
    long long time = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:floder]) {
        NSDate *data = [[[NSFileManager defaultManager] attributesOfItemAtPath:floder error:nil] objectForKey:NSFileModificationDate];
        time = [data timeIntervalSince1970]*1000;
    }
    NSString *jsonCode = [NSString stringWithFormat:@"BackupTimeAndDirectoryResponse('%@',%lld,'%@')",mac,time,floder];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 备份数据到手机
- (void)BackupDataRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    NSString *docu = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
    NSString *root = [docu stringByAppendingPathComponent:mac];
    if (![[NSFileManager defaultManager] fileExistsAtPath:root]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:root withIntermediateDirectories:true attributes:nil error:nil];
    }
    NSString *floder = [root stringByAppendingPathComponent:@"cacheData.txt"];
    BOOL res = false;
    NSString *json = [object objectForKey:@"data"];
    if (json.length) {
        NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
         res = [[NSFileManager defaultManager] createFileAtPath:floder contents:data attributes:nil];
    }
    NSString *jsonCode = [NSString stringWithFormat:@"BackupDataResponse('%@',%d,)",mac,res];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 从手机恢复备份数据
- (void)BackupRecoveryDataRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    NSString *docu = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
    NSString *root = [docu stringByAppendingPathComponent:mac];
    NSString *floder = [root stringByAppendingPathComponent:@"cacheData.txt"];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:floder];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSString *json = [ToolHandle toJsonString:dic];
    
    NSString *jsonCode = [NSString stringWithFormat:@"BackupRecoveryDataResponse('%@','%@',)",mac,json];
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
        SEL sel = NSSelectorFromString([self.funDic objectForKey:message.name]);
        if ([self respondsToSelector:sel]) {
//            [[BluetoothManager shareInstance] regeistDelegate:self];
            [[HandlingDataModel shareInstance] regeistDelegate:self];
            [self performSelector:sel withObject:message.body];
        }
    }
}


@end
