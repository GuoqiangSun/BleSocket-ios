//
//  BaseModel.m
//  BluetoothSocket
//
//  Created by Mac on 2018/6/7.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "BaseModel.h"

@interface BaseModel ()

@end

@implementation BaseModel


- (void)registFunctionWithWeb:(WKWebView *)web
{
    
}

- (NSData *)getData:(uint8_t)da
{
    NSData *data = [[NSData alloc] initWithBytes:&da length:sizeof(da)];
    return data;
}

- (void)sendDataWithMac:(NSString *)mac data:(NSMutableData *)data
{
    [[BluetoothManager shareInstance] sendData:data];
}


@end
