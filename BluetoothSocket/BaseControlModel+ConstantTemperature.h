//
//  BaseControlModel+ConstantTemperature.h
//  BluetoothSocket
//
//  Created by Mac on 2019/6/4.
//  Copyright © 2019 QiXing. All rights reserved.
//

#import "BaseControlModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseControlModel (ConstantTemperature)

///温度-恒温模式列表数据查询 0x45
- (void)timingConstTemperatureDataRequest:(NSDictionary *)dict;

///温度-恒温模式设置 新建/编辑 0x43
- (void)timingConstTemperatureDataSet:(NSDictionary *)dict;

///温度-恒温模式删除 0x47
- (void)timingConstTemperatureDataDelete:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
