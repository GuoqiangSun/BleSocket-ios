//
//  BaseModel.h
//  BluetoothSocket
//
//  Created by Mac on 2018/6/7.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface BaseModel : NSObject

@property (nonatomic, strong) NSArray *funArr;
@property (nonatomic, strong) NSDictionary *funDic;
@property (nonatomic, strong) WKWebView *web;

+ (instancetype)shareInstance;

- (void)registFunctionWithWeb:(WKWebView *)web;

- (NSData *)getData:(uint8_t)da;

- (void)sendDataWithMac:(NSString *)mac data:(NSMutableData *)data;


@end
