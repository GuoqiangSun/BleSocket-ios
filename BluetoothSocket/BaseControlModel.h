//
//  BaseControlModel.h
//  WiFiSocket
//
//  Created by Mac on 2018/6/11.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "BaseModel.h"

@interface BaseControlModel : BaseModel<HandlingDataModelDelegate>

@property (nonatomic, strong) NSMutableArray *lanConverArr;

@property (nonatomic, copy) void(^deviceSwitchUpdate)(BOOL state, NSString *deviceMac);

- (void)sendData:(NSMutableData *)data mac:(NSString *)mac;

@end
