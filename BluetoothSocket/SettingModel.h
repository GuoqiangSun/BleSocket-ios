//
//  SettingModel.h
//  WiFiSocket
//
//  Created by Mac on 2018/6/11.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "BaseModel.h"
@interface SettingModel : BaseModel<HandlingDataModelDelegate>

@property (nonatomic, strong) NSMutableArray *lanConverArr;

@property (nonatomic, copy) void(^reNameDeviceSucess)(NSString *mac);


@end
