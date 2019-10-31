//
//  BluetoothManager.h
//  BluetoothSocket
//
//  Created by Mac on 2018/4/8.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BluetoothManagerDelegate <NSObject>

/**
 *  告知刷新蓝牙列表
 */
- (void)refreshPeripheralList:(NSMutableArray <CBPeripheral *>*)peripheralList;

/**
 *  告知连接蓝牙
 */
- (void)connectedPeripheral:(CBPeripheral *)peripheral;

/**
 *  告知断开蓝牙
 */
- (void)disconnectedPeripheral:(CBPeripheral *)peripheral;

@end

@interface BluetoothManager : NSObject

@property (nonatomic, assign) BOOL reconnect;


/**
 *  获取单例对象
 */
+ (BluetoothManager *)shareInstance;

- (void)initCentralManager;
/**
 *  搜索or停止搜索
 *  @param state true为蓝牙搜索 false 关闭蓝牙搜索
 */
- (void)scanOrStop:(BOOL)state;

/**
 *  注册代理
 */
- (void)regeistDelegate:(id)obj;

/**
 *  取消代理
 */
- (void)unRegistDelegate:(id)obj;

/**
 *  发送数据
 * param data 发送数据
 */
- (void)sendData:(NSMutableData *)data;

/**
 *  连接蓝牙
 *  @prama peripheral 连接指定的外设
 */
- (void)connectedPeripheral:(CBPeripheral *)peripheral;

/**
 *  断开蓝牙
 * @prama peripheral 断开指定的外设
 */
- (void)disconnectedPeripheral:(CBPeripheral *)peripheral;

- (void)realDisconnect;

@end
