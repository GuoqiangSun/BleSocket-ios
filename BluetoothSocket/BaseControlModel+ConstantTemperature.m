//
//  BaseControlModel+ConstantTemperature.m
//  BluetoothSocket
//
//  Created by Mac on 2019/6/4.
//  Copyright © 2019 QiXing. All rights reserved.
//

#import "BaseControlModel+ConstantTemperature.h"

@implementation BaseControlModel (ConstantTemperature)

- (void)timingConstTemperatureDataRequest:(NSDictionary *)dict{
    
    [self constTemperatureList:1 :dict];
    [self constTemperatureList:2 :dict];
    
}

- (void)constTemperatureList:(NSInteger )mode :(NSDictionary *)dict{
    
    int8_t type= 0x02;
    int8_t cmd = 0x45;
    int8_t modeType = mode;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:modeType]];
    NSString *mac = [dict objectForKey:@"mac"];
    [self sendData:data mac:mac];
    
}

#pragma mark    温度-恒温模式列表数据返回 0x46
- (void)timingConstTemperatureDataResponse:(NSDictionary *)dict deviceMac:(NSString *)deviceMac{
    
    NSData *data = [dict objectForKey:@"data"];
    uint8_t reserve = 7;
    uint8_t headLoc = 1+reserve;
    
    NSMutableData *listData = [NSMutableData data];
    [listData appendData:[data subdataWithRange:NSMakeRange(headLoc, data.length - headLoc - 2)]];
    Byte *byte = (Byte *)[listData bytes];
    NSInteger listLength = 12;
    NSInteger listCount = listData.length/listLength;
    NSInteger patternModel = byte[0];
    NSMutableArray *listArray = [NSMutableArray array];
    
    for (int i = 0; i < listCount; i++) {
        
        NSInteger index = i*listLength;
        NSInteger ID = byte[index + 1];
        NSInteger model = byte[index + 2];
        NSInteger startup = byte[index + 3];
        NSInteger minTemp = byte[index + 4];
        NSInteger minTempF = byte[index + 5];
        NSInteger maxTemp = byte[index + 6];
        NSInteger maxTempF = byte[index + 7];
        NSInteger week = byte[index + 8];
        NSInteger startHour = byte[index + 9];
        NSInteger startMinit = byte[index + 10];
        NSInteger endHour = byte[index + 11];
        NSInteger endMinit = byte[index + 12];
        
        NSDictionary *listDict = @{
                                   @"id":@(ID),
                                   @"model":@(model),
                                   @"startup":@(startup),
                                   @"minTemp":@(minTemp),
                                   @"minTempF":@(minTempF),
                                   @"maxTemp":@(maxTemp),
                                   @"maxTempF":@(maxTempF),
                                   @"week":@(week),
                                   @"startHour":@(startHour),
                                   @"startMinit":@(startMinit),
                                   @"endHour":@(endHour),
                                   @"endMinit":@(endMinit)
                                   };
        
        [listArray addObject:listDict];
        
    }
    
    NSString *json = [ToolHandle toJsonString:listArray];
    NSString *jsCode = [NSString stringWithFormat:@"timingConstTemperatureDataResponse('%@','%ld','%@')",deviceMac,patternModel,json];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
}

- (void)timingConstTemperatureDataSet:(NSDictionary *)dict{
    
    int8_t type= 0x02;
    int8_t cmd = 0x43;
    int8_t idc = [dict[@"id"] integerValue];
    int8_t model = [dict[@"model"] integerValue];
    int8_t startup = [dict[@"startup"] integerValue];
    int8_t minTemp = [dict[@"minTemp"] integerValue];
    int8_t minTempF = [dict[@"minTempF"] integerValue];
    int8_t maxTemp = [dict[@"maxTemp"] integerValue];
    int8_t maxTempF = [dict[@"maxTempF"] integerValue];
    int8_t week = [dict[@"week"] integerValue];
    int8_t startHour = [dict[@"startHour"] integerValue];
    int8_t startMinit = [dict[@"startMinit"] integerValue];
    int8_t endHour = [dict[@"endHour"] integerValue];
    int8_t endMinit = [dict[@"endMinit"] integerValue];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:idc]];
    [data appendData:[self getData:model]];
    [data appendData:[self getData:startup]];
    [data appendData:[self getData:minTemp]];
    [data appendData:[self getData:minTempF]];
    [data appendData:[self getData:maxTemp]];
    [data appendData:[self getData:maxTempF]];
    [data appendData:[self getData:week]];
    [data appendData:[self getData:startHour]];
    [data appendData:[self getData:startMinit]];
    [data appendData:[self getData:endHour]];
    [data appendData:[self getData:endMinit]];
    
    NSString *mac = [dict objectForKey:@"mac"];
    [self sendData:data mac:mac];
    
    NSLog(@"温度-恒温模式设置返回 0x43 %@",data);
    
}

#pragma mark    温度-恒温模式设置 返回 0x44
- (void)timingConstTemperatureDataSetResponse:(NSDictionary *)dict deviceMac:(NSString *)deviceMac{
    
    NSData *data = [dict objectForKey:@"data"];
    uint8_t reserve = 7;
    uint8_t headLoc = 1+reserve;
    NSMutableData *listData = [NSMutableData data];
    [listData appendData:[data subdataWithRange:NSMakeRange(headLoc, data.length - headLoc - 2)]];
    Byte *byte = (Byte *)[listData bytes];
    
    NSUInteger result = [[dict objectForKey:@"result"] integerValue];
    NSInteger ID = byte[0];
    NSInteger model = byte[1];
    NSInteger startup = byte[2];
    NSInteger minTemp = byte[3];
    NSInteger minTempF = byte[4];
    NSInteger maxTemp = byte[5];
    NSInteger maxTempF = byte[6];
    NSInteger week = byte[7];
    NSInteger startHour = byte[8];
    NSInteger startMinit = byte[9];
    NSInteger endHour = byte[10];
    NSInteger endMinit = byte[11];
    
    //    NSString *json = [ToolHandle toJsonString:dict];
    NSString *jsonCode = [NSString stringWithFormat:@"timingConstTemperatureDataSetResponse('%@',%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld)"
                          ,deviceMac
                          ,result
                          ,ID
                          ,model
                          ,startup
                          ,minTemp
                          ,minTempF
                          ,maxTemp
                          ,maxTempF
                          ,week
                          ,startHour
                          ,startMinit
                          ,endHour
                          ,endMinit
                          ];
    
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
}

- (void)timingConstTemperatureDataDelete:(NSDictionary *)dict{
    
    int8_t type= 0x02;
    int8_t cmd = 0x47;
    int8_t idc = [dict[@"id"] integerValue];
    int8_t model = [dict[@"model"] integerValue];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:idc]];
    [data appendData:[self getData:model]];
    
    NSString *mac = [dict objectForKey:@"mac"];
    [self sendData:data mac:mac];
    
}

#pragma mark    温度-恒温模式删除 返回 0x48
- (void)timingConstTemperatureDataDeleteResponse:(NSDictionary *)dict deviceMac:(NSString *)deviceMac{
    
    NSData *data = [dict objectForKey:@"data"];
    uint8_t reserve = 7;
    uint8_t headLoc = 1+reserve;
    NSMutableData *listData = [NSMutableData data];
    [listData appendData:[data subdataWithRange:NSMakeRange(headLoc, data.length - headLoc - 2)]];
    Byte *byte = (Byte *)[listData bytes];
    
    NSUInteger result = [[dict objectForKey:@"result"] integerValue];
    NSInteger ID = byte[0];
    NSInteger model = byte[1];
    
    NSString *jsonCode = [NSString stringWithFormat:@"timingConstTemperatureDataDeleteResponse('%@',%ld,%ld,%ld)",deviceMac,result,ID,model];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
}

@end
