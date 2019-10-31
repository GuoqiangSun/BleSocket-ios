
//
//  HandlingDataModel.h
//  BluetoothSocket
//
//  Created by Mac on 2018/7/16.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HandlingDataModelDelegate <NSObject>

@optional

/**
 *  固件操作
 */

- (void)FirmwareOperationResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  告知上报数据
 */
- (void)ReportingRealTimeData:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  查询设备历史数据返回
 */
- (void)deviceHistoryDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  五分钟上报电量数据
 */
- (void)deviceHistoryReportDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  查询设备累计参数返回
 */
- (void)deviceAccumulationParameterResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  查询设备费率返回
 */
- (void)deviceRateResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  告知继电器开关状态
 */
- (void)powerSwitchResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  查询倒计时返回
 */
- (void)CountdownResult:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  设置倒计时返回
 */
- (void)powerSwitchCountdownResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  定温湿度设置回复
 */
- (void)alarmTemperatureValueResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  查询定温湿度回复
 */
- (void)temperatureAndHumidityDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  设置高级定时温度返回
 */
- (void)alarmTimerAndTemperatureValueResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  高级定时温度列表返回
 */
- (void)timingAndTemperatureDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  查询定时列表数据回复
 */
- (void)commonPatternListDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  定时操作回复
 */
- (void)commonPatternTimingResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  上报定时结束
 */
- (void)reportendoftime:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  查询校准时间
 */
- (void)queryCalibrationTimeResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  校准时间回复
 */
- (void)calibrationTimeResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  查询定费数据返回
 */
- (void)spendingCountdownDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  设置定量定费返回
 */
- (void)spendingCountdownAlarmResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  设备重命名
 */
- (void)reNameResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  查询设备名称
 */
- (void)queryDeviceNameResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  温度传感器状态返回
 */
- (void)temperatureSensorStateResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  温度传感器状态上报返回
 */
- (void)temperatureSensorReportStateResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

///温度-恒温模式设置 返回 0x44
- (void)timingConstTemperatureDataSetResponse:(NSDictionary *)dict deviceMac:(NSString *)deviceMac;

///温度-恒温模式列表数据返回 0x46
- (void)timingConstTemperatureDataResponse:(NSDictionary *)dict deviceMac:(NSString *)deviceMac;

///温度-恒温模式删除 返回 0x48
- (void)timingConstTemperatureDataDeleteResponse:(NSDictionary *)dict deviceMac:(NSString *)deviceMac;

/******************************************设置界面操作******************************************/
/**
 *  设置电压警告值回复
 */
- (void)settingAlarmVoltageResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  查询电压警告值回复
 */
-(void)queryAlarmVoltageResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  设置电流告警值回复
 **/
-(void)settingAlarmCurrentResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  查询电流告警值回复
 **/
-(void)queryAlarmCurrentResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  设置功率告警值回复
 **/
-(void)settingAlarmPowerResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  查询功率告警值回复
 **/
-(void)queryAlarmPowerResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  设置温度单位回复
 **/
-(void)settingTemperatureUnitResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  查询温度单位回复
 **/
-(void)queryTemperatureUnitResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  设置货币单位告回复
 **/
-(void)settingMonetarytUnitResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  查询货币单位回复
 **/
-(void)queryMonetarytUnitResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  设置本地电价回复
 **/
-(void)settingLocalElectricityResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  查询本地电价回复
 **/
-(void)queryLocalElectricityResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  恢复出厂设置回复
 **/
-(void)settingResumeSetupResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  指示灯返回
 */
-(void)indicatorLightStateResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/******************************************灯光控制******************************************/
/**
 *  普通小夜灯返回
 */
- (void)ordinaryNightLightResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  查询小夜灯设置数据返回
 */
- (void)nightLightSettingResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  智能夜灯开关返回
 */
- (void)nightLightSwitchResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  定时夜灯返回
 */
//- (void)timingNightLightResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  彩灯设置数据返回
 */
- (void)colourLampSettingResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  彩灯开关返回
 */
- (void)colourLampSwitchResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  彩灯控制返回
 */
- (void)colourLampControlResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  彩灯当前模式返回
 */
- (void)colourLampModeQueryResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
/**
 *  彩灯模式列表数据返回
 */
- (void)colourLampModeListQueryResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  USB开关返回
 */
- (void)USBSwitchStateRequest:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/******************************************局域网通信******************************************/

/**
 *  7种状态回调
 */
-(void)selectSevenStatusResponse:(NSDictionary *)dict deviceMac:(NSString *)deviceMac;
/**
 *  绑定设备返回
 */
-(void)bindDeviceResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  绑定设备返回
 */
-(void)unBindDeviceResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  获取token码返回
 */
- (void)requestTokenResonse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  局域网连接回调
 */
- (void)requestLANConnectionResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  心跳包回复
 */
- (void)heartBeatResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;

/**
 *  局域网休眠回调
 */
-(void)requestLanConnectionSleepResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;


@end

@interface HandlingDataModel : NSObject

@property (nonatomic, copy) void(^findDeviceHandler)(NSDictionary *dic,NSDictionary *macDic);
@property (nonatomic, copy) void(^reNameDeviceHandler)(NSDictionary *dic);
@property (nonatomic, copy) void(^updateWifiInfomation)(NSDictionary *dic);
@property (nonatomic, copy) void(^showToastHandler)(void);
@property (nonatomic, strong) NSMutableArray *deviceArr;

+ (instancetype)shareInstance;

/**
 *  注册代理
 */
- (void)regegistDelegate:(id)obj;

/**
 *  取消代理
 */
- (void)unRegistDelegate:(id)obj;


// 处理局域网和广域网透传消息
//- (void)handlingRecevieData:(NSData *)data  deviceIdentifiy:(NSString *)deviceIdentifiy fromAddress:(NSString *)address;
- (void)handlingRecevieData:(NSData *)data deviceMac:(NSString *)deviceMac fromAddress:(NSString *)address;
@end


////
////  HandlingDataModel.h
////  BluetoothSocket
////
////  Created by Mac on 2018/7/16.
////  Copyright © 2018年 QiXing. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
//
//@protocol HandlingDataModelDelegate <NSObject>
//
///**
// *  告知上报数据
// */
//- (void)ReportingRealTimeData:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  查询设备历史数据返回
// */
//- (void)deviceHistoryDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  查询设备累计参数返回
// */
//- (void)deviceAccumulationParameterResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  查询设备费率返回
// */
//- (void)deviceRateResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  告知继电器开关状态
// */
//- (void)powerSwitchResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  查询倒计时返回
// */
//- (void)CountdownResult:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  设置倒计时返回
// */
//- (void)powerSwitchCountdownResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  定温湿度设置回复
// */
//- (void)alarmHumidityAndTemperatureValue:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  查询定温湿度回复
// */
//- (void)temperatureAndHumidityDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  温度传感器状态返回
// */
//- (void)temperatureSensorStateResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  温度传感器状态上报返回
// */
//- (void)temperatureSensorReportStateResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  查询定时列表数据回复
// */
//- (void)commonPatternListDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  定时操作回复
// */
//- (void)commonPatternTimingResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  上报定时结束
// */
//- (void)reportendoftime:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  校准时间回复
// */
//- (void)calibrationTimeResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  查询定费数据返回
// */
//- (void)spendingCountdownDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  设置定量定费返回
// */
//- (void)spendingCountdownAlarmResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  设备重命名
// */
//- (void)reNameResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  设置电压警告值回复
// */
//- (void)settingAlarmVoltageResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
///**
// *  查询电压警告值回复
// */
//-(void)queryAlarmVoltageResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
///**
// *  设置电流告警值回复
// **/
//-(void)settingAlarmCurrentResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
///**
// *  查询电流告警值回复
// **/
//-(void)queryAlarmCurrentResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
///**
// *  设置功率告警值回复
// **/
//-(void)settingAlarmPowerResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
///**
// *  查询功率告警值回复
// **/
//-(void)queryAlarmPowerResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
///**
// *  设置温度单位回复
// **/
//-(void)settingTemperatureUnitResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
///**
// *  查询温度单位回复
// **/
//-(void)queryTemperatureUnitResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
///**
// *  设置货币单位告回复
// **/
//-(void)settingMonetarytUnitResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
///**
// *  查询货币单位回复
// **/
//-(void)queryMonetarytUnitResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
///**
// *  设置本地电价回复
// **/
//-(void)settingLocalElectricityResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
///**
// *  查询本地电价回复
// **/
//-(void)queryLocalElectricityResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
///**
// *  恢复出厂设置回复
// **/
//-(void)settingResumeSetupResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  指示灯返回
// */
//-(void)indicatorLightStateResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  绑定设备返回
// */
//-(void)bindDeviceResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  获取token码返回
// */
//- (void)requestTokenResonse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  局域网连接回调
// */
//- (void)requestLANConnectionResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
///**
// *  局域网休眠回调
// */
//-(void)requestLanConnectionSleepResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac;
//
//
//@end
//
//@interface HandlingDataModel : NSObject
//
//@property (nonatomic, copy) void(^sendFindAck)(void);
//@property (nonatomic, copy) void(^findDeviceHandler)(NSDictionary *dic,NSDictionary *macDic);
//
//
//+ (instancetype)shareInstance;
//
///**
// *  注册代理
// */
//- (void)regegistDelegate:(id)obj;
//
///**
// *  取消代理
// */
//- (void)unRegistDelegate:(id)obj;
//
//- (void)handlingRecevieData:(NSData *)data deviceMac:(NSString *)deviceMac fromAddress:(NSString *)address;
//
//@end
