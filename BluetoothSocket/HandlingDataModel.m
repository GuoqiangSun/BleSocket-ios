

//
//  HandlingDataModel.m
//  BluetoothSocket
//
//  Created by Mac on 2018/7/16.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "HandlingDataModel.h"
#import <objc/runtime.h>

#import "BluetoothModel.h"
#import "BaseControlModel.h"    //设备基础任务管理
#import "SettingModel.h"        //设备进阶设置管理


@interface HandlingDataModel ()
{
    uint8_t useDataLoc; //获取有效数据部分起始位置 不包含result
}
@property (nonatomic, strong) NSMutableData *recevieData;
@property (nonatomic, weak) id<HandlingDataModelDelegate>delegate;
@property (nonatomic, strong) NSMutableDictionary *deviceDic;

@property (nonatomic, strong) NSDictionary *delegeDic;

@end

@implementation HandlingDataModel


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
        self.recevieData = [[NSMutableData alloc] init];
        self.deviceDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)regegistDelegate:(id)obj
{
    self.delegate = obj;
}

- (void)unRegistDelegate:(id)obj
{
    self.delegate = nil;
}


- (NSDictionary *)delegeDic
{
    return @{
//             [NSString stringWithFormat:@"%d-%d",0x02,0x04]:[HomeModel shareInstance],    //时间校准回复
//             [NSString stringWithFormat:@"%d-%d",0x02,0x10]:[HomeModel shareInstance],    //查询当前时间回复
//
//             [NSString stringWithFormat:@"%d-%d",0x01,0x06]:[ConfigWiFiModel shareInstance],    //绑定与解绑回复
             
             [NSString stringWithFormat:@"%d-%d",0x01,0x36]:[BaseControlModel shareInstance],    //设置开关控制返回
             [NSString stringWithFormat:@"%d-%d",0x01,0x38]:[BaseControlModel shareInstance],    //查询开关状态返回
             
             [NSString stringWithFormat:@"%d-%d",0x02,0x02]:[BaseControlModel shareInstance],    //设置电源开关返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x06]:[BaseControlModel shareInstance],    //设置定时回复
             [NSString stringWithFormat:@"%d-%d",0x02,0x08]:[BaseControlModel shareInstance],    //设置倒计时回复
             [NSString stringWithFormat:@"%d-%d",0x02,0x0a]:[BaseControlModel shareInstance],    //设置定温度回复
             [NSString stringWithFormat:@"%d-%d",0x02,0x0c]:[BaseControlModel shareInstance],    //查询开关状态返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x0e]:[BaseControlModel shareInstance],    //查询倒计时回复
             [NSString stringWithFormat:@"%d-%d",0x02,0x12]:[BaseControlModel shareInstance],    //查询定温度返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x14]:[BaseControlModel shareInstance],    //查询定时回复
             [NSString stringWithFormat:@"%d-%d",0x02,0x16]:[BaseControlModel shareInstance],    //设置定电定费回复
             [NSString stringWithFormat:@"%d-%d",0x02,0x18]:[BaseControlModel shareInstance],    //查询定电定费
             [NSString stringWithFormat:@"%d-%d",0x02,0x2C]:[BaseControlModel shareInstance],    //设置温湿度定时模式返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x2E]:[BaseControlModel shareInstance],    //查询温湿度定时模式返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x3A]:[BaseControlModel shareInstance],
             //查询7种状态
             [NSString stringWithFormat:@"%d-%d",0x02,0x40]:[BaseControlModel shareInstance],
             //查询传感器返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x44]:[BaseControlModel shareInstance],    //温温度-恒温模式设置返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x46]:[BaseControlModel shareInstance],    //温度-恒温模式列表数据返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x48]:[BaseControlModel shareInstance],    //温度-恒温模式删除返回
             [NSString stringWithFormat:@"%d-%d",0x03,0x01]:[BaseControlModel shareInstance],    //上报温湿度
             [NSString stringWithFormat:@"%d-%d",0x03,0x03]:[BaseControlModel shareInstance],    //上报功率电压
             [NSString stringWithFormat:@"%d-%d",0x03,0x05]:[BaseControlModel shareInstance],    //上报定温度完成
             [NSString stringWithFormat:@"%d-%d",0x03,0x07]:[BaseControlModel shareInstance],    //上报倒计时
             [NSString stringWithFormat:@"%d-%d",0x03,0x09]:[BaseControlModel shareInstance],    //上报定时结束
             [NSString stringWithFormat:@"%d-%d",0x03,0x11]:[BaseControlModel shareInstance],    //上报传感器状态
             [NSString stringWithFormat:@"%d-%d",0x03,0x13]:[BaseControlModel shareInstance],    //返回传感器状态
             [NSString stringWithFormat:@"%d-%d",0x01,0x0c]:[SettingModel shareInstance],    //重命名设备名称
             [NSString stringWithFormat:@"%d-%d",0x02,0x0e]:[SettingModel shareInstance],    //查询设备名称
             [NSString stringWithFormat:@"%d-%d",0x02,0x3C]:[SettingModel shareInstance],    //控制指示灯返回
             [NSString stringWithFormat:@"%d-%d",0x02,0x3E]:[SettingModel shareInstance],    //查询指示灯返回
             [NSString stringWithFormat:@"%d-%d",0x01,0x10]:[SettingModel shareInstance],    //设置电压告警回复
             [NSString stringWithFormat:@"%d-%d",0x01,0x12]:[SettingModel shareInstance],    //查询电压告警回复
             [NSString stringWithFormat:@"%d-%d",0x01,0x14]:[SettingModel shareInstance],    //设置电流告警回复
             [NSString stringWithFormat:@"%d-%d",0x01,0x16]:[SettingModel shareInstance],    //查询电流告警回复
             [NSString stringWithFormat:@"%d-%d",0x01,0x18]:[SettingModel shareInstance],    //设置功率g告警回复
             [NSString stringWithFormat:@"%d-%d",0x01,0x1a]:[SettingModel shareInstance],    //查询功率告警回复
             [NSString stringWithFormat:@"%d-%d",0x01,0x1c]:[SettingModel shareInstance],    //设置温度单位回复
             [NSString stringWithFormat:@"%d-%d",0x01,0x1e]:[SettingModel shareInstance],    //查询温度单位回复
             [NSString stringWithFormat:@"%d-%d",0x01,0x20]:[SettingModel shareInstance],    //设置货币单位回复
             [NSString stringWithFormat:@"%d-%d",0x01,0x22]:[SettingModel shareInstance],    //查询货币单位回复
             [NSString stringWithFormat:@"%d-%d",0x01,0x24]:[SettingModel shareInstance],    //设置本地电价回复
             [NSString stringWithFormat:@"%d-%d",0x01,0x26]:[SettingModel shareInstance],    //查询本地电价回复
             [NSString stringWithFormat:@"%d-%d",0x01,0x28]:[SettingModel shareInstance],    //恢复出厂设置回复
             
             [NSString stringWithFormat:@"%d-%d",0x02,0x04]:[BluetoothModel shareInstance],    //校准时间
             [NSString stringWithFormat:@"%d-%d",0x02,0x10]:[BluetoothModel shareInstance],    //查询校准时间
             
//             [NSString stringWithFormat:@"%d-%d",0x01,0x0a]:[FirmwareUpdateModel shareInstance],        //固件查询升级操作
//
//             [NSString stringWithFormat:@"%d-%d",0x02,0x26]:[LightControlModel shareInstance],       //设置rgb回复
//             [NSString stringWithFormat:@"%d-%d",0x02,0x2A]:[LightControlModel shareInstance],       //查询rgb回复
//             [NSString stringWithFormat:@"%d-%d",0x02,0x30]:[LightControlModel shareInstance],        //查询彩灯模式返回
//             [NSString stringWithFormat:@"%d-%d",0x02,0x32]:[LightControlModel shareInstance],        //设置彩灯模式返回
//             [NSString stringWithFormat:@"%d-%d",0x02,0x34]:[LightControlModel shareInstance],        //查询所有彩灯模式返回
//             [NSString stringWithFormat:@"%d-%d",0x02,0x36]:[LightControlModel shareInstance],        //小夜灯定时设置返回
//             [NSString stringWithFormat:@"%d-%d",0x02,0x38]:[LightControlModel shareInstance],        //小夜灯查询返回
//
//             [NSString stringWithFormat:@"%d-%d",0x02,0x1a]:[QueryHistoryModel shareInstance],       //查询一天历史数据回复
//             [NSString stringWithFormat:@"%d-%d",0x02,0x20]:[QueryHistoryModel shareInstance],       //查询费率回复
//             [NSString stringWithFormat:@"%d-%d",0x02,0x22]:[QueryHistoryModel shareInstance],       //查询设备累计参数
//             [NSString stringWithFormat:@"%d-%d",0x03,0x0B]:[QueryHistoryModel shareInstance],    //上报电量数据
//
//             [NSString stringWithFormat:@"%d-%d",0x01,0x02]:[UDPSocket shareInstance],    //心跳回复
//             [NSString stringWithFormat:@"%d-%d",0x01,0x2e]:[UDPSocket shareInstance],    //请求token返回
//             [NSString stringWithFormat:@"%d-%d",0x01,0x30]:[UDPSocket shareInstance],    //局域网连接握手返回
//             [NSString stringWithFormat:@"%d-%d",0x01,0x32]:[UDPSocket shareInstance],    //局域网休眠
//             [NSString stringWithFormat:@"%d-%d",0x02,0x0a]:[UDPSocket shareInstance],
//
//             [NSString stringWithFormat:@"%d-%d",0x01,0x04]:[MqMessageResponseModel shareInstance],    //发现设备回复
//             [NSString stringWithFormat:@"%d-%d",0x01,0x0e]:[MqMessageResponseModel shareInstance],    //查询设备名称回复
//             [NSString stringWithFormat:@"%d-%d",0x01,0x3E]:[MqMessageResponseModel shareInstance],    //查询WiFiSSID
             };
}

- (void)handlingRecevieData:(NSData *)data deviceMac:(NSString *)deviceMac fromAddress:(NSString *)address
{
 
    //    NSLog(@"特征值更新......................%@",data);
    uint8_t reserve = 2;  //协议预留字节长度
    Byte type = 0x00;     //指令类型
    Byte cmd = 0x00;      //指令
    NSInteger len = -1;
    Byte *test = (Byte*)[data bytes];//得到data1中bytes的指针。
    for (NSInteger i=0; i<data.length; i++) {
        Byte byte = test[i];
        if (byte== 0xff && self.recevieData.length) {
            self.recevieData = [[NSMutableData alloc]init];
        }
        [self.recevieData appendData:[data subdataWithRange:NSMakeRange(i, 1)]];
        if (byte == 0xee) {
            len = i+1;
            break;
        }
    }

    if (self.recevieData.length) {
        uint8_t ffx = 0xff;
        NSData *ff = [self.recevieData subdataWithRange:NSMakeRange(0, 1)];
        if (![ff isEqualToData:[NSData dataWithBytes:&ffx length:1]]) {
            self.recevieData = [[NSMutableData alloc] init];
        }
    }

    if (self.recevieData.length) {
        uint8_t eex = 0xee;
        NSData *ee = [self.recevieData subdataWithRange:NSMakeRange(self.recevieData.length-1, 1)];
        if (![ee isEqualToData:[NSData dataWithBytes:&eex length:1]]) {
            return;
        }
    }

    if (self.recevieData.length<2) {
        NSLog(@"无效数据....................");
        return;
    }

    self.recevieData = [ToolHandle escapingSpecialCharacters:self.recevieData];
    NSRange range = [self.recevieData rangeOfData:[ToolHandle getData:0xee] options:NSDataSearchAnchored range:NSMakeRange(0, self.recevieData.length-1)];
    if (self.recevieData.length>0 && range.length ) {
        NSMutableData *da1 = [NSMutableData dataWithData:self.recevieData];
        self.recevieData = [NSMutableData data];
        [self handlingRecevieData:da1 deviceMac:deviceMac fromAddress:address];
        return;
    }

    NSLog(@"特征值更新......................%@",self.recevieData);
    //获取result之后第一个有效数据位置
    useDataLoc = 3+reserve+2+1;
    Byte *testByte = (Byte*)[self.recevieData bytes];
    for(int i = 0;i<[self.recevieData length];i++){
        if (i==3+reserve) {
            type = [self getByteWithoffset:3+reserve];//testByte[i];
        }else if (i==4+reserve){
            cmd =[self getByteWithoffset:4+reserve];//testByte[i];
        }
    }

    // 指令发生错误
    if (type == 0x00 && cmd == 0x00) {
        uint8_t result = [self getByteWithoffset:useDataLoc-1];
        uint8_t errType = [self getByteWithoffset:useDataLoc];
        uint8_t errCmd = [self getByteWithoffset:useDataLoc+1];
        //        result 0x00 数据错误 0x02校验错误 0x03 命令类型错误 0x04 命令错误 0x05 有效数据长度错误
        DDLog(@"控制指令发生错误...............%d..........%d..........%d.",result,errType,errCmd);
    }
    
    //指令控制失败
    BOOL result = (BOOL)[self getByteWithoffset:useDataLoc-1];
    result = !result;
    if (result == false && type != 0x03) {
        DDLog(@"当前指令返回失败...............%d..........%d.........",type,cmd);
    }
    
    
    //根据指令找到代理
    self.delegate = nil;
    id classIva = [self.delegeDic objectForKey:[NSString stringWithFormat:@"%d-%d",type,cmd]];
    if (!classIva) {
        DDLog(@"当前指令返回找不到接受者对象...............%d..........%d.........",type,cmd);
//        return;
    }
    self.delegate = classIva;
    
    if ((testByte[5+2] == 0x06) || (testByte[5+8] == 0x06)) {

    }
    if (type == 0x01) {
        BOOL result = (BOOL)[self getByteWithoffset:useDataLoc-1];
        result = !result;
        if (cmd == 0x02) {
            //心跳回复
            if ([self getByteWithoffset:useDataLoc-1] == 0x03) {

            }
            NSLog(@"/n/n...............心跳回复.....................");
        }else if(cmd == 0x04 && self.recevieData.length>50){
            //发现设备回复
        }else if (cmd == 0x06){
            //绑定回复
            if ([self.delegate respondsToSelector:@selector(bindDeviceResponse:deviceMac:)]) {
                NSInteger snLoc = useDataLoc+1;
                if (self.recevieData.length>snLoc+32+32+6) {
                    NSData *sn = [self.recevieData subdataWithRange:NSMakeRange(snLoc, 32)];
                    NSData *mac = [self.recevieData subdataWithRange:NSMakeRange(snLoc+32+32, 6)];
                    [self.delegate bindDeviceResponse:@{
                                                        @"result":@(result),
                                                        @"sn":sn,
                                                        @"mac":mac,
                                                        } deviceMac:deviceMac];
                }
            }
        }else if (cmd == 0x0c) {
            //重命名设备名称
            if ([self.delegate respondsToSelector:@selector(reNameResponse:deviceMac:)]) {
                [self.delegate reNameResponse:@{@"result":@(result)} deviceMac:deviceMac];
            }
        }else if (cmd == 0x10) {
            //设置电压告警值回复
            if ([self.delegate respondsToSelector:@selector(settingAlarmVoltageResponse:deviceMac:)]) {
                [self.delegate settingAlarmVoltageResponse:@{@"result":@(result)} deviceMac:deviceMac];
            }
        }else if (cmd == 0x12){
            NSString *Voltage = [NSString stringWithFormat:@"%d",([self getByteWithoffset:useDataLoc]<<8)+[self getByteWithoffset:useDataLoc+1]];
            //查询电压告警值回复
            if ([self.delegate respondsToSelector:@selector(queryAlarmVoltageResponse:deviceMac:)]) {
                [self.delegate queryAlarmVoltageResponse:@{@"result":@(result),@"Voltage":Voltage} deviceMac:deviceMac];
            }
        }else if (cmd == 0x14){
            //设置电流警告值回复
            if ([self.delegate respondsToSelector:@selector(settingAlarmCurrentResponse:deviceMac:)]) {
                [self.delegate settingAlarmCurrentResponse:@{@"result":@(result)} deviceMac:deviceMac];
            }
        }else if (cmd == 0x16){
            //查询电流警告值回复
            if ([self.delegate respondsToSelector:@selector(queryAlarmCurrentResponse:deviceMac:)]) {
                [self.delegate queryAlarmCurrentResponse:@{@"result":@(result),@"electricity":@([self getByteWithoffset:useDataLoc])} deviceMac:deviceMac];
            }
        }else if (cmd == 0x18){
            //设置功率警告值回复
            if ([self.delegate respondsToSelector:@selector(settingAlarmPowerResponse:deviceMac:)]) {
                [self.delegate settingAlarmPowerResponse:@{@"result":@(result)} deviceMac:deviceMac];
            }
        }else if (cmd == 0x1a){
            //查询设置功率警告值回复
            NSString *power = [NSString stringWithFormat:@"%d",([self getByteWithoffset:useDataLoc]<<8)+[self getByteWithoffset:useDataLoc+1]];
            if ([self.delegate respondsToSelector:@selector(queryAlarmPowerResponse:deviceMac:)]) {
                [self.delegate queryAlarmPowerResponse:@{@"result":@(result),@"power":power} deviceMac:deviceMac];
            }
        }else if (cmd == 0x1c){
            //设置温度单位回复
            if ([self.delegate respondsToSelector:@selector(settingTemperatureUnitResponse:deviceMac:)]) {
                [self.delegate settingTemperatureUnitResponse:@{@"result":@(result)} deviceMac:deviceMac];
            }
        }else if (cmd == 0x1e){
            //查询温度单位回复
            if ([self.delegate respondsToSelector:@selector(queryTemperatureUnitResponse:deviceMac:)]) {
                [self.delegate queryTemperatureUnitResponse:@{@"result":@(result),@"type":@([self getByteWithoffset:useDataLoc])} deviceMac:deviceMac];
            }
        }else if (cmd == 0x20){
            //设置货币单位回复
            if ([self.delegate respondsToSelector:@selector(settingMonetarytUnitResponse:deviceMac:)]) {
                [self.delegate settingMonetarytUnitResponse:@{@"result":@(result)} deviceMac:deviceMac];
            }
        }else if (cmd == 0x22){
            //查询货币单位回复
            if ([self.delegate respondsToSelector:@selector(queryMonetarytUnitResponse:deviceMac:)]) {
                [self.delegate queryMonetarytUnitResponse:@{@"result":@(result),@"type":@([self getByteWithoffset:useDataLoc])} deviceMac:deviceMac];
            }
        }else if (cmd == 0x24){
            //设置本地电价回复
            if ([self.delegate respondsToSelector:@selector(settingLocalElectricityResponse:deviceMac:)]) {
                [self.delegate settingLocalElectricityResponse:@{@"result":@(result)} deviceMac:deviceMac];
            }
        }else if (cmd == 0x26){
            //查询本地电价回复
            NSString *price = [NSString stringWithFormat:@"%d",([self getByteWithoffset:useDataLoc]<<8)+[self getByteWithoffset:useDataLoc+1]];
            if ([self.delegate respondsToSelector:@selector(queryLocalElectricityResponse:deviceMac:)]) {
                [self.delegate queryLocalElectricityResponse:@{@"result":@(result),@"price":price} deviceMac:deviceMac];
            }
        }else if (cmd == 0x28){
            //恢复出厂设置回复
            if ([self.delegate respondsToSelector:@selector(settingResumeSetupResponse:deviceMac:)]) {
                [self.delegate settingResumeSetupResponse:@{@"result":@(result)} deviceMac:deviceMac];
            }
        }else if (cmd == 0x2b){
            //请求注册

        }else if (cmd == 0x2e){
            //请求token码回复
            NSData *tokenData = [self.recevieData subdataWithRange:NSMakeRange(useDataLoc+4, 4)];
            NSLog(@"............请求token码返回返回....................%d",result);
//            if (result) {
//                [[NSUserDefaults standardUserDefaults] setObject:tokenData forKey:deviceMac];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//                [[UDPSocket shareInstance] requestLANConnection:deviceMac];
//            }else{
//                [[NSUserDefaults standardUserDefaults] removeObjectForKey:deviceMac];
//            }

            if ([self.delegate respondsToSelector:@selector(requestTokenResonse:deviceMac:)]) {
                [self.delegate requestTokenResonse:@{@"result":@(result),@"token":tokenData} deviceMac:deviceMac];
            }
        }else if (cmd == 0x30){
            //局域网连接返回
            NSLog(@"............局域网连接返回....................%d",result);
//            if (!result) {
//                [[NSUserDefaults standardUserDefaults] removeObjectForKey:deviceMac];
//                [[UDPSocket shareInstance] requestToekn];
//                UDPSocket.shareInstance.isConnected = false;
//            }else{
//                UDPSocket.shareInstance.isConnected = true;
//                [[UDPSocket shareInstance] startHeartBeatTiemr];
//            }
            if ([self.delegate respondsToSelector:@selector(requestLANConnectionResponse:deviceMac:)]) {
                [self.delegate requestLANConnectionResponse:@{@"result":@(result)} deviceMac:deviceMac];
            }
        }else if (cmd == 0x32){
            //局域网休眠
            if ([self.delegate respondsToSelector:@selector(requestLanConnectionSleepResponse:deviceMac:)]) {
                [self.delegate requestLanConnectionSleepResponse:@{@"result":@(testByte[useDataLoc-1])} deviceMac:deviceMac];
            }
        }

    }else if (type == 0x02) {
        BOOL result = (BOOL)[self getByteWithoffset:useDataLoc-1];
        result = !result;
        if (cmd == 0x02) {
            //设置电源开关回复
            if ([self.delegate respondsToSelector:@selector(powerSwitchResponse:deviceMac:)]) {
                [self.delegate powerSwitchResponse:@{@"state":@([self getByteWithoffset:useDataLoc]),
                                                     @"result":@(result),
                                                     } deviceMac:deviceMac];
            }
        }else if (cmd == 0x04){
            //时间校准回复
            if ([self.delegate respondsToSelector:@selector(calibrationTimeResponse:deviceMac:)]) {
                [self.delegate calibrationTimeResponse:@{@"result":@(result)} deviceMac:deviceMac];
            }
        }else if (cmd == 0x06){
            
            NSInteger model = [self getByteWithoffset:useDataLoc];
            NSInteger ID = [self getByteWithoffset:useDataLoc + 1];
            BOOL sWitch;
            if (model == 1) {
                sWitch = (BOOL)[self getByteWithoffset:useDataLoc + 4];
                result = (BOOL)[self getByteWithoffset:useDataLoc + 7];
            }else{
                sWitch = (BOOL)[self getByteWithoffset:useDataLoc + 8];
                result = (BOOL)[self getByteWithoffset:useDataLoc + 11];
            }
            
            //设置定时回复
            if ([self.delegate respondsToSelector:@selector(commonPatternTimingResponse:deviceMac:)]) {
                [self.delegate commonPatternTimingResponse:@{@"result":@(result),@"model":@(model),@"id":@(ID),@"switch":@(sWitch)} deviceMac:deviceMac];
            }
        }else if(cmd == 0x08){
            //设置倒计时回复
            BOOL switc = ([self getByteWithoffset:useDataLoc] == 0x01)?true:false;
            if ([self.delegate respondsToSelector:@selector(powerSwitchCountdownResponse:deviceMac:)]) {
                [self.delegate powerSwitchCountdownResponse:@{@"state":@(switc),
                                                              @"result":@(result),
                                                              @"switch":@([self getByteWithoffset:useDataLoc+1]),
                                                              } deviceMac:deviceMac];
            }
        }else if (cmd == 0x0a){
            //设置定温湿度回复
            if ([self.delegate respondsToSelector:@selector(alarmTemperatureValueResponse:deviceMac:)]){
                [self.delegate alarmTemperatureValueResponse:
                 @{@"result":@(result),@"state":@([self getByteWithoffset:useDataLoc]),@"mode":@([self getByteWithoffset:useDataLoc+1]),@"type":@([self getByteWithoffset:useDataLoc+2])} deviceMac:deviceMac];
            } 
        }else if (cmd == 0x0c){
            //查询开关状态回复
            if ([self.delegate respondsToSelector:@selector(powerSwitchResponse:deviceMac:)]) {
                [self.delegate powerSwitchResponse:@{@"state":@([self getByteWithoffset:useDataLoc]),
                                                     @"result":@(result),
                                                     } deviceMac:deviceMac];
            }
        }else if (cmd == 0x0e){
            //查询倒计时回复
            if ([self.delegate respondsToSelector:@selector(CountdownResult:deviceMac:)]) {
                NSInteger realHour;
                NSInteger realMinute;
                NSInteger seconds;
                if ([self getByteWithoffset:useDataLoc+7] == 0x00) {
                    realHour =0;
                    realMinute = 0;
                    seconds = 0;
                }else{
                    realHour = [self getByteWithoffset:useDataLoc+4];
                    realMinute = [self getByteWithoffset:useDataLoc+5];
                    seconds = [self getByteWithoffset:useDataLoc+6];
                    if ([self getByteWithoffset:useDataLoc+8] == 0x00) {
                        seconds = 0;
                    }
                }
                [self.delegate CountdownResult:@{@"result":@(result),
                                                 @"state":@([self getByteWithoffset:useDataLoc]),
                                                 @"switch":@([self getByteWithoffset:useDataLoc+1]),
                                                 @"hour":@([self getByteWithoffset:useDataLoc+2]),
                                                 @"minute":@([self getByteWithoffset:useDataLoc+3]),
                                                 @"seconds":@(seconds),
                                                 @"realHour":@(realHour),
                                                 @"realMinute":@(realMinute),
                                                 } deviceMac:deviceMac];
                
                NSDictionary *dic = @{@"result":@(result),
                                      @"state":@([self getByteWithoffset:useDataLoc]),
                                      @"switch":@([self getByteWithoffset:useDataLoc+1]),
                                      @"hour":@([self getByteWithoffset:useDataLoc+2]),
                                      @"minute":@([self getByteWithoffset:useDataLoc+3]),
                                      @"seconds":@(seconds),
                                      @"realHour":@(realHour),
                                      @"realMinute":@(realMinute),
                                      };
                
//                NSString *json = [ToolHandle toJsonString:dic];
//                NSString *str = [NSString stringWithFormat:@"%@:%@",self.recevieData,json];
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"倒计时查询返回数据" message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alert show];
            }
        }else if (cmd == 0x10){
            //查询当前时间回复
            if ([self.delegate respondsToSelector:@selector(queryCalibrationTimeResponse:deviceMac:)]) {
                [self.delegate queryCalibrationTimeResponse:@{@"data":self.recevieData} deviceMac:deviceMac];
            }
        }else if (cmd == 0x12){
            //查询定温湿度返回
            NSString *ding = [[NSString alloc] initWithFormat:@"%d.%d",(int8_t)[self getByteWithoffset:useDataLoc+3],(int8_t)[self getByteWithoffset:useDataLoc+4]];
            NSString *curr = [[NSString alloc] initWithFormat:@"%d.%d",(int8_t)[self getByteWithoffset:useDataLoc+5],(int8_t)[self getByteWithoffset:useDataLoc+6]];
            BOOL state = [self getByteWithoffset:useDataLoc] == 0x01 ? true : false;
            if ([self.delegate respondsToSelector:@selector(temperatureAndHumidityDataResponse:deviceMac:)]) {
                [self.delegate temperatureAndHumidityDataResponse:@{@"result":@(result),@"state":@(state), @"mode":@([self getByteWithoffset:useDataLoc+1]),@"currentValue":curr,@"alarmValue":ding,@"type":@([self getByteWithoffset:useDataLoc+2])} deviceMac:deviceMac];
            }
        }else if (cmd == 0x14){
            
            if (result == NO) {
                NSLog(@"result结果  返回失败0x14");
                return;
            }
            
            //查询定时回复
            if ([self.delegate respondsToSelector:@selector(commonPatternListDataResponse:deviceMac:)]) {
                [self.delegate commonPatternListDataResponse:@{@"data":self.recevieData} deviceMac:deviceMac];
            }
        }else if (cmd == 0x16){
            //设置定电定量回复
            if ([self.delegate respondsToSelector:@selector(spendingCountdownAlarmResponse:deviceMac:)]) {
                [self.delegate spendingCountdownAlarmResponse:@{@"result":@(result),@"mode":@([self getByteWithoffset:useDataLoc+1]),@"state":@([self getByteWithoffset:useDataLoc])} deviceMac:deviceMac];
            }
        } else if (cmd == 0x18){
            //查询定量定电
            if ([self.delegate respondsToSelector:@selector(spendingCountdownDataResponse:deviceMac:)]) {
                [self.delegate spendingCountdownDataResponse:@{@"data":self.recevieData} deviceMac:deviceMac];
            }
        }else if (cmd == 0x1a){
            //查询某一天的历史数据回复
            if ([self.delegate respondsToSelector:@selector(deviceHistoryDataResponse:deviceMac:)]) {
                [self.delegate deviceHistoryDataResponse:@{@"result":@(result),@"year":@([self getByteWithoffset:useDataLoc]),
                                                           @"month":@([self getByteWithoffset:useDataLoc+1]),@"day":@([self getByteWithoffset:useDataLoc+2]),
                                                           @"days":@([self getByteWithoffset:useDataLoc+3]),@"electricQuantity":@([self getByteWithoffset:useDataLoc+4]),
                                                           @"consume":@([self getByteWithoffset:useDataLoc+5]),@"interval":@([self getByteWithoffset:useDataLoc+6])
                                                           } deviceMac:deviceMac];            }
        }else if (cmd == 0x20){
            //查询费率回复
            if ([self.delegate respondsToSelector:@selector(deviceRateResponse:deviceMac:)]) {
                [self.delegate deviceRateResponse:@{@"result":@(result),@"firstHour":@([self getByteWithoffset:useDataLoc]),
                                                    @"firstMinute":@([self getByteWithoffset:useDataLoc+1]),@"firstPrice":@([self getByteWithoffset:useDataLoc+2]),
                                                    @"sencondHour":@([self getByteWithoffset:useDataLoc+3]),@"secondMinute":@([self getByteWithoffset:useDataLoc+4]),
                                                    @"secondPrice":@([self getByteWithoffset:useDataLoc+5])
                                                    } deviceMac:deviceMac];
            }
        }else if (cmd == 0x22){
            //查询设备累计参数
            if ([self.delegate respondsToSelector:@selector(deviceAccumulationParameterResponse:deviceMac:)]) {
                [self.delegate deviceAccumulationParameterResponse:@{@"result":@(result),@"electricQuantity":@([self getByteWithoffset:useDataLoc]),
                                                                     @"totalTime":@([self getByteWithoffset:useDataLoc+1]),@"GHG":@([self getByteWithoffset:useDataLoc+2])
                                                                     } deviceMac:deviceMac];
            }
        }else if (cmd == 0x3A){
            //查询传感器状态
            if ([self.delegate respondsToSelector:@selector(temperatureSensorStateResponse:deviceMac:)]) {
                [self.delegate temperatureSensorStateResponse:@{@"mode":@([self getByteWithoffset:useDataLoc]),
                                                                @"status":@([self getByteWithoffset:useDataLoc+1])} deviceMac:deviceMac];
            }
        }else if (cmd == 0x3C){
            //一键控制所有指示灯状态返回
            if ([self.delegate respondsToSelector:@selector(indicatorLightStateResponse:deviceMac:)]) {
                [self.delegate indicatorLightStateResponse:@{@"seq":@([self getByteWithoffset:useDataLoc]),
                                                             @"state":@([self getByteWithoffset:useDataLoc+1])} deviceMac:deviceMac];
            }
        }else if (cmd == 0x3E){
            //查询一键控制所有指示灯状态返回
            if ([self.delegate respondsToSelector:@selector(indicatorLightStateResponse:deviceMac:)]) {
                [self.delegate indicatorLightStateResponse:@{@"seq":@([self getByteWithoffset:useDataLoc]),
                                                             @"state":@([self getByteWithoffset:useDataLoc+1])} deviceMac:deviceMac];
            }
        }else if (cmd == 0x40){
            //查询7种状态
            if ([self.delegate respondsToSelector:@selector(selectSevenStatusResponse:deviceMac:)]) {
                uint8_t status0 = [self getByteWithoffset:useDataLoc];
                int power = status0 & 0x01;
                int colorLight = status0 & 0x02;
                int sleepLight = status0 & 0x04;
                int UsbPower = status0 & 0x08;
                int pilotLight = status0 & 0x10;
                
                uint8_t status1 = [self getByteWithoffset:useDataLoc + 1];
                int colorLightTimer = status1 & 0x01;
                int sleepLightTimer = status1 & 0x02;
                
                uint8_t status2 = [self getByteWithoffset:useDataLoc+2];
                int timer = status2 & 0x01;
                int highTimer = status2 & 0x02;
                int countDown = status2 & 0x04;
                int UsbTimer = status2 & 0x08;
                
                uint8_t status3 = [self getByteWithoffset:useDataLoc + 3];
                int temperature = status3 & 0x01;
                int temperatureSensing = status3 & 0x02;
                int humidity = status3 & 0x04;
                int highTemperature = status3 &0x08;
                
                uint8_t status4 = [self getByteWithoffset:useDataLoc+4];
                int setMeasure = status4 & 0x01;
                int setCost = status4 & 0x2;
                
                [self.delegate selectSevenStatusResponse:@{@"power":@(power),
                                                           @"colorLight":@(colorLight),
                                                           @"sleepLight":@(sleepLight),
                                                           @"UsbPower":@(UsbPower),
                                                           @"pilotLight":@(pilotLight),
                                                           
                                                           @"colorLightTimer":@(colorLightTimer),
                                                           @"sleepLightTimer":@(sleepLightTimer),
                                                           
                                                           @"timer":@(timer),
                                                           @"highTimer":@(highTimer),
                                                           @"countDown":@(countDown),
                                                           @"UsbTimer":@(UsbTimer),
                                                           
                                                           @"temperature":@(temperature),
                                                           @"temperatureSensing":@(temperatureSensing),
                                                           @"humidity":@(humidity),
                                                           @"highTemperature":@(highTemperature),
                                                           
                                                           @"setMeasure":@(setMeasure),
                                                           @"setCost":@(setCost)
                                                           } deviceMac:deviceMac];
                
            }
            
            
        }else if (cmd == 0x44){
            
            if ([self.delegate respondsToSelector:@selector(timingConstTemperatureDataSetResponse:deviceMac:)]) {
                [self.delegate timingConstTemperatureDataSetResponse:@{@"result":@([self getByteWithoffset:useDataLoc-1]),@"data":self.recevieData
                } deviceMac:deviceMac];
            
            }
            
        }else if (cmd == 0x46){
            
            if ([self getByteWithoffset:useDataLoc-1] == 1) {
                NSLog(@"result结果  返回失败0x46");
                return;
            }
            
            if ([self.delegate respondsToSelector:@selector(timingConstTemperatureDataResponse:deviceMac:)]) {
                [self.delegate timingConstTemperatureDataResponse:@{@"result":@(result),@"data":self.recevieData
                } deviceMac:deviceMac];
            }
            
        }else if (cmd == 0x48){
            
            if ([self.delegate respondsToSelector:@selector(timingConstTemperatureDataDeleteResponse:deviceMac:)]) {
                [self.delegate timingConstTemperatureDataDeleteResponse:@{@"result":@([self getByteWithoffset:useDataLoc-1]),@"data":self.recevieData
                } deviceMac:deviceMac];
                
            }
            
        }
        
        
    }else if (type == 3) {
        uint8_t startLoc = useDataLoc-1;
        if (cmd == 0x01) {
            //上报温湿度
            NSString *lower = [[NSString alloc] initWithFormat:@"%d.%d",[self getByteWithoffset:startLoc],[self getByteWithoffset:startLoc]];
            NSString *humidity = [[NSString alloc] initWithFormat:@"%d.%d",(int8_t)testByte[9],(int8_t)testByte[10]];
            NSDictionary *dic = @{
                                  @"temperature":@{
                                          @"value" : @([lower floatValue]),
                                          @"alarmVal" : @(100),
                                          },
                                  @"humidity":@{
                                          @"value" : @([humidity floatValue]),
                                          @"alarmVal" : @(100),
                                          },
                                  };
            if ([self.delegate respondsToSelector:@selector(ReportingRealTimeData:deviceMac:)]) {
                [self.delegate ReportingRealTimeData:dic deviceMac:deviceMac];
            }

        }else if (cmd == 0x02){
            //上报温湿度回复
        }else if (cmd == 0x03){
            //上报功率电压
            NSString *gonglv = [[NSString alloc] initWithFormat:@"%d",([self getByteWithoffset:startLoc]<<8)+[self getByteWithoffset:startLoc+1]];
            NSString *averagelv = [[NSString alloc] initWithFormat:@"%d",([self getByteWithoffset:startLoc+2]<<8)+[self getByteWithoffset:startLoc+3]];
            NSString *maxlv = [[NSString alloc] initWithFormat:@"%d",([self getByteWithoffset:startLoc+4]<<8)+[self getByteWithoffset:startLoc+5]];
            NSString *frequency = [[NSString alloc] initWithFormat:@"%d.%d",[self getByteWithoffset:startLoc+6],[self getByteWithoffset:startLoc+7]];
            NSString *dianya = [[NSString alloc] initWithFormat:@"%d.%d",([self getByteWithoffset:startLoc+8]<<8)+[self getByteWithoffset:startLoc+9],[self getByteWithoffset:startLoc+10]];
            NSString *dianliu = [[NSString alloc] initWithFormat:@"%d.%d",[self getByteWithoffset:startLoc+11],[self getByteWithoffset:startLoc+12]];
            NSDictionary *dic = @{
                                  @"power":@{
                                          @"value":gonglv,
                                          @"averageValue":averagelv,
                                          @"maximumValue":maxlv
                                          },
                                  @"voltage" : dianya,
                                  @"electricity" : dianliu,
                                  @"frequency" : frequency,
                                  };
            if ([self.delegate respondsToSelector:@selector(ReportingRealTimeData:deviceMac:)]) {
                [self.delegate ReportingRealTimeData:dic deviceMac:deviceMac];
            }
        }else if (cmd == 0x04){
            //上报功率电压回复
        }else if (cmd == 0x05){
            //上报定温度完成
            NSString *ding = [[NSString alloc] initWithFormat:@"%d.%d",(int8_t)[self getByteWithoffset:useDataLoc+3],(int8_t)[self getByteWithoffset:useDataLoc+4]];
            NSString *curr = [[NSString alloc] initWithFormat:@"%d.%d",(int8_t)[self getByteWithoffset:useDataLoc+5],(int8_t)[self getByteWithoffset:useDataLoc+6]];
            BOOL state = [self getByteWithoffset:useDataLoc-1] == 0x01 ? true : false;
            if ([self.delegate respondsToSelector:@selector(temperatureAndHumidityDataResponse:deviceMac:)]) {
                [self.delegate temperatureAndHumidityDataResponse:@{@"result":@(true),
                                                            @"state":@(state),
                                                            @"mode":@([self getByteWithoffset:useDataLoc+1]),
                                                            @"currentValue":curr,
                                                            @"alarmValue":ding,
                                                            @"type":@([self getByteWithoffset:useDataLoc+2])} deviceMac:deviceMac];
            }
            if ([self.delegate respondsToSelector:@selector(powerSwitchResponse:deviceMac:)]) {
                [self.delegate powerSwitchResponse:@{                                                                @"state":@([self getByteWithoffset:useDataLoc])} deviceMac:deviceMac];
            }
        }else if (cmd == 0x07){
            //上报倒计时
            NSInteger realHour;
            NSInteger realMinute;
            NSInteger seconds;
            if ([self getByteWithoffset:startLoc+7] == 0x00) {
                realHour =0;
                realMinute = 0;
                seconds = 0;
            }else{
                realHour = [self getByteWithoffset:startLoc+4];
                realMinute = [self getByteWithoffset:startLoc+5];
                seconds = [self getByteWithoffset:startLoc+6];
                if ([self getByteWithoffset:startLoc+8] == 0x00) {
                    seconds = 0;
                }
            }
            if ([self.delegate respondsToSelector:@selector(CountdownResult:deviceMac:)]) {
                [self.delegate CountdownResult:@{@"result":@(true),
                                                 @"state":@([self getByteWithoffset:startLoc]),
                                                 @"switch":@([self getByteWithoffset:startLoc+1]),
                                                 @"hour":@([self getByteWithoffset:startLoc+2]),
                                                 @"minute":@([self getByteWithoffset:startLoc+3]),
                                                 @"seconds":@(seconds),
                                                 @"realHour":@(realHour),
                                                 @"realMinute":@(realMinute),
                                                 } deviceMac:deviceMac];
            }
            NSDictionary *dic = @{@"result":@(true),
                                  @"state":@([self getByteWithoffset:startLoc]),
                                  @"switch":@([self getByteWithoffset:startLoc+1]),
                                  @"hour":@([self getByteWithoffset:startLoc+2]),
                                  @"minute":@([self getByteWithoffset:startLoc+3]),
                                  @"seconds":@(seconds),
                                  @"realHour":@(realHour),
                                  @"realMinute":@(realMinute),
                                  };
//            NSString *json = [ToolHandle toJsonString:dic];
//            NSString *str = [NSString stringWithFormat:@"%@:%@",self.recevieData,json];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"倒计时上报返回数据" message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alert show];
        }else if (cmd == 0x09){
            
            NSInteger model = [self getByteWithoffset:useDataLoc];
            NSInteger ID = [self getByteWithoffset:useDataLoc + 1];
            BOOL sWitch;
            if (model == 1) {
                sWitch = (BOOL)[self getByteWithoffset:useDataLoc + 2];
                result = (BOOL)[self getByteWithoffset:useDataLoc + 6];
            }else{
                sWitch = (BOOL)[self getByteWithoffset:useDataLoc + 6];
                result = (BOOL)[self getByteWithoffset:useDataLoc + 11];
            }
            
            //上报定时结束
            if ([self.delegate respondsToSelector:@selector(reportendoftime:deviceMac:)]) {
                [self.delegate reportendoftime:@{@"result":@(result),@"model":@(model),@"id":@(ID),@"switch":@(sWitch)} deviceMac:deviceMac];
            }
            
        }else if (cmd == 0x11){
            //上报传感器状态
            if ([self.delegate respondsToSelector:@selector(temperatureSensorReportStateResponse:deviceMac:)]) {
                [self.delegate temperatureSensorReportStateResponse:@{@"mode":@([self getByteWithoffset:useDataLoc]-1),
                                                                @"status":@([self getByteWithoffset:useDataLoc])} deviceMac:deviceMac];
            }
        }else if (cmd == 0x13){
            
            if ([self.delegate respondsToSelector:@selector(selectSevenStatusResponse:deviceMac:)]) {
                
                uint8_t status0 = [self getByteWithoffset:useDataLoc];
                int power = status0 & 0x01;
                int colorLight = status0 & 0x02;
                int sleepLight = status0 & 0x04;
                int UsbPower = status0 & 0x08;
                int pilotLight = status0 & 0x10;
                
                uint8_t status1 = [self getByteWithoffset:useDataLoc + 1];
                int colorLightTimer = status1 & 0x01;
                int sleepLightTimer = status1 & 0x02;
                
                uint8_t status2 = [self getByteWithoffset:useDataLoc+2];
                int timer = status2 & 0x01;
                int highTimer = status2 & 0x02;
                int countDown = status2 & 0x04;
                int UsbTimer = status2 & 0x08;
                
                uint8_t status3 = [self getByteWithoffset:useDataLoc + 3];
                int temperature = status3 & 0x01;
                int temperatureSensing = status3 & 0x02;
                int humidity = status3 & 0x04;
                int highTemperature = status3 &0x08;
                
                uint8_t status4 = [self getByteWithoffset:useDataLoc+4];
                int setMeasure = status4 & 0x01;
                int setCost = status4 & 0x2;
                
                [self.delegate selectSevenStatusResponse:@{@"power":@(power),
                                                           @"colorLight":@(colorLight),
                                                           @"sleepLight":@(sleepLight),
                                                           @"UsbPower":@(UsbPower),
                                                           @"pilotLight":@(pilotLight),
                                                           
                                                           @"colorLightTimer":@(colorLightTimer),
                                                           @"sleepLightTimer":@(sleepLightTimer),
                                                           
                                                           @"timer":@(timer),
                                                           @"highTimer":@(highTimer),
                                                           @"countDown":@(countDown),
                                                           @"UsbTimer":@(UsbTimer),
                                                           
                                                           @"temperature":@(temperature),
                                                           @"temperatureSensing":@(temperatureSensing),
                                                           @"humidity":@(humidity),
                                                           @"highTemperature":@(highTemperature),
                                                           
                                                           @"setMeasure":@(setMeasure),
                                                           @"setCost":@(setCost)
                                                           } deviceMac:deviceMac];
                
            }
            
        }
    }else{

    }
    self.recevieData = [NSMutableData data];
    if (len> -1 && data.length>len) {
        [self.recevieData appendData:[data subdataWithRange:NSMakeRange(len, data.length-len)]];
        if (self.recevieData.length &&
            [self.recevieData rangeOfData:[ToolHandle getData:0xff] options:NSDataSearchBackwards range:NSMakeRange(0, 1)].length &&
            [self.recevieData rangeOfData:[ToolHandle getData:0xee] options:NSDataSearchBackwards range:NSMakeRange(self.recevieData.length-1, 1)].length) {
            [self handlingRecevieData:self.recevieData deviceMac:deviceMac fromAddress:address];
        }else{

        }
    }
}


- (NSData *)replaceNoUtf8:(NSData *)data
{
    char aa[] = {'A','A','A','A','A','A'};                      //utf8最多6个字符，当前方法未使用
    NSMutableData *md = [NSMutableData dataWithData:data];
    int loc = 0;
    while(loc < [md length])
    {
        char buffer;
        [md getBytes:&buffer range:NSMakeRange(loc, 1)];
        if((buffer & 0x80) == 0)
        {
            loc++;
            continue;
        }
        else if((buffer & 0xE0) == 0xC0)
        {
            loc++;
            if (loc>=data.length) {
                continue;
            }
            [md getBytes:&buffer range:NSMakeRange(loc, 1)];
            if((buffer & 0xC0) == 0x80)
            {
                loc++;
                continue;
            }
            loc--;
            //非法字符，将这个字符（一个byte）替换为A
            [md replaceBytesInRange:NSMakeRange(loc, 1) withBytes:aa length:1];
            loc++;
            continue;
        }
        else if((buffer & 0xF0) == 0xE0)
        {
            loc++;
            if (loc>=data.length) {
                continue;
            }
            [md getBytes:&buffer range:NSMakeRange(loc, 1)];
            if((buffer & 0xC0) == 0x80)
            {
                loc++;
                [md getBytes:&buffer range:NSMakeRange(loc, 1)];
                if((buffer & 0xC0) == 0x80)
                {
                    loc++;
                    continue;
                }
                loc--;
            }
            loc--;
            //非法字符，将这个字符（一个byte）替换为A
            [md replaceBytesInRange:NSMakeRange(loc, 1) withBytes:aa length:1];
            loc++;
            continue;
        }
        else
        {
            //非法字符，将这个字符（一个byte）替换为A
            [md replaceBytesInRange:NSMakeRange(loc, 1) withBytes:aa length:1];
            loc++;
            continue;
        }
    }

    return md;
}

- (uint8_t)getByteWithoffset:(int)offset
{
    if (offset > self.recevieData.length) {
        return 0x00;
    }
    Byte *testByte = (Byte*)[self.recevieData bytes];
    return testByte[offset];
}



@end
