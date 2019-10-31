//
//  BluetoothModel.h
//  BluetoothSocket
//
//  Created by Mac on 2018/4/8.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"


@interface BluetoothModel : BaseModel<BluetoothManagerDelegate>

@property (nonatomic, copy) void(^openBluetoothSetting)(void);

- (void)ModelTypeAdaptiveRequest:(NSDictionary *)object;

@end
