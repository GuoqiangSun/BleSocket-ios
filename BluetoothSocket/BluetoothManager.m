

//
//  BluetoothManager.m
//  BluetoothSocket
//
//  Created by Mac on 2018/4/8.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "BluetoothManager.h"
#import <UIKit/UIKit.h>
#import "NSData+UTF8.h"
#import "HandlingDataModel.h"

static NSInteger delayTime = 200;

@interface BluetoothManager ()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic, strong) HandlingDataModel *handlingModel;
@property (nonatomic, weak) id<BluetoothManagerDelegate>delegate;
@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) CBPeripheral *myPeripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;
@property (nonatomic ,strong) NSMutableArray <CBPeripheral *>*peripheralArr;
@property (nonatomic, strong) NSMutableData *recevieData;
@property (nonatomic, assign) NSInteger reconnectedNum;
@property (nonatomic, assign) BOOL interruptBySelf;
@property (nonatomic, assign) BOOL searchState;
@property (nonatomic, assign) NSInteger reconncetNum;
@property (nonatomic, strong) NSTimer *delayTimer;


@end

@implementation BluetoothManager

+ (BluetoothManager *)shareInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance initCentralManager];
    });
    return instance;
}

- (HandlingDataModel *)handlingModel
{
    if (!_handlingModel) {
        _handlingModel = [HandlingDataModel shareInstance];
    }
    return _handlingModel;
}

- (void)startDelayTimer:(CBPeripheral *)perpheral
{
    if (_delayTimer) {
        [_delayTimer invalidate];
        _delayTimer = nil;
    }
    _delayTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(delayConnectPerpherial:) userInfo:perpheral repeats:false];
    [[NSRunLoop currentRunLoop] addTimer:_delayTimer forMode:NSRunLoopCommonModes];
}

- (void)delayConnectPerpherial:(NSTimer *)timer
{
//    CBPeripheral *perpheral = timer.userInfo;
//    if (perpheral && perpheral.state != CBPeripheralStateConnected) {
//        self.interruptBySelf = true;
//        [self.manager cancelPeripheralConnection:perpheral];
//        if ([self.delegate respondsToSelector:@selector(disconnectedPeripheral:)]) {
//            [self.delegate disconnectedPeripheral:perpheral];
//        }
//    }
}

#pragma mark 蓝牙搜索筛选UUID
- (void)searchFilter
{
    if(!_manager){
        [self initCentralManager];
    }
    NSLog(@"getInFround.......");
    CBUUID *uuid1 = [CBUUID UUIDWithString:@"00001812-0000-1000-8000-00805f9b34fb"];
    CBUUID *uuid2 = [CBUUID UUIDWithString:@"0000fee7-0000-1000-8000-00805f9b34fb"];
    
    [self.manager scanForPeripheralsWithServices:@[uuid1,uuid2] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @(true)}];
//    [self.manager scanForPeripheralsWithServices:@[] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @(true)}];
}

- (void)regeistDelegate:(id)obj
{
    self.delegate = obj;
}

- (void)unRegistDelegate:(id)obj
{
    self.delegate = nil;
}

- (void)sendData:(NSMutableData *)data
{
    if (data != nil && self.myPeripheral.state == CBPeripheralStateConnected && self.characteristic) {
        [self.myPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    }
}

- (void)refreshPerheralList
{
    if ([self.delegate respondsToSelector:@selector(refreshPeripheralList:)]) {
        [self.delegate refreshPeripheralList:self.peripheralArr];
    }
}

- (void)connectedPeripheral:(CBPeripheral *)peripheral
{
    for (CBPeripheral *per in self.peripheralArr) {
        if (per.state == CBPeripheralStateConnected) {
            [self.manager cancelPeripheralConnection:per];
        }
    }
    for (CBPeripheral *per in self.peripheralArr) {
        if ([per.identifier isEqual:peripheral.identifier]) {
//            NSString *ident = [[NSString alloc] initWithFormat:@"%@",peripheral.identifier];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:peripheral.name message:ident delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alert show];
            self.interruptBySelf = false;
            [self.manager connectPeripheral:per options:nil];
            [self startDelayTimer:per];
            break;
        }
    }
}

- (void)disconnectedPeripheral:(CBPeripheral *)peripheral
{
    [self scanOrStop:false];
    for (CBPeripheral *per in self.peripheralArr) {
        if ([per.identifier isEqual:peripheral.identifier]) {
            [self.manager cancelPeripheralConnection:per];
            self.interruptBySelf = true;
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:StorePerpheral];
            NSLog(@"主动断开设备..................");
            break;
        }
    }
}

#pragma mark 初始化蓝牙搜索器
- (void)initCentralManager
{
    if (!_manager) {
        self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        self.peripheralArr = [NSMutableArray array];
    }
}

- (void)scanOrStop:(BOOL)state
{
    //延时0.5秒是界面为了刷新效果的显示
    if (!_manager) {
        [self initCentralManager];
        [self performSelector:@selector(searchFilter) withObject:nil afterDelay:0.5];
    }
    
    self.searchState = state;
    if (state && self.manager.state == CBCentralManagerStatePoweredOn) {
        self.peripheralArr = [NSMutableArray array];
        if (self.myPeripheral) {
            [self.peripheralArr addObject:self.myPeripheral];
        }
        [self performSelector:@selector(refreshPerheralList) withObject:nil afterDelay:0.5];
//        [self refreshPerheralList];
        [self searchFilter];
    }else{
        [self.manager stopScan];
        self.peripheralArr = [NSMutableArray array];
        if (self.myPeripheral) {
            [self.peripheralArr addObject:self.myPeripheral];
        }
        [self performSelector:@selector(refreshPerheralList) withObject:nil afterDelay:0.5];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSInteger type ;
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            NSLog(@"状态未知");
            type = 1;
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"重置状态");
            type = 1;
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"不支持");
            type = 1;
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"未授权");
            type = 1;
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"关闭");
            type = 1;
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"开启");
            type = 4;
            if (self.searchState) {
                [self scanOrStop:true];
            }
        default:
            break;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateState" object:nil userInfo:@{@"state":@(central.state)}];
}

#pragma mark 扫描到外设
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
//    NSString *str = [[NSString alloc] initWithData:advertisementData[@"kCBAdvDataManufacturerData"] encoding:NSUTF8StringEncoding];
    
    if (self.peripheralArr.count) {
        BOOL exist = false;
        for (CBPeripheral *per in self.peripheralArr) {
            if ([self isPeripheral:per equalPeripheral:peripheral]) {
                exist = true;
            }
        }
        if (!exist) {
            [self.peripheralArr addObject:peripheral];
            [self refreshPerheralList];
            
        }
    }else{
        [self.peripheralArr addObject:peripheral];
        [self refreshPerheralList];
    }
    
    if ([peripheral.name isEqualToString:@"MTS700"] ||
        [peripheral.name isEqualToString:@"st10"] ||
        [peripheral.name isEqualToString:@"ST10"] ||
        [peripheral.name isEqualToString:@"St10"] ||
        [peripheral.name isEqualToString:@"sT10"]) {
        
    }
    
    NSString *identfiy;
    NSString *name;

    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:StorePerpheral];
    if (dic) {
        identfiy = dic[@"mac"];
        name = dic[@"name"];
    }
    NSString *ident = [NSString stringWithFormat:@"%@",peripheral.identifier];
    if ([self isPeripheral:peripheral equalPeripheral:self.myPeripheral] && self.myPeripheral.state != CBPeripheralStateConnected) {
        [self scanOrStop:false];
        if (self.reconncetNum>3) {
            self.myPeripheral = nil;
            self.reconncetNum = 0;
            [self.manager cancelPeripheralConnection:peripheral];
            return;
        }
        self.reconncetNum++;
        [self.manager connectPeripheral:peripheral options:nil];
        [self startDelayTimer:peripheral];
        NSLog(@"发现掉线设备进行重连...................................");
    }else if([identfiy isEqualToString:ident] && self.reconnect && [name isEqualToString:peripheral.name]){
        self.reconnect = false;
        self.myPeripheral = peripheral;
        [self scanOrStop:false];
        NSLog(@"进入app重连...................................");
        [self.manager connectPeripheral:self.myPeripheral options:nil];
        [self startDelayTimer:peripheral];
    }
    NSLog(@"...扫描到外设.................>%@",peripheral.name);
}

#pragma mark 连接外设成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
//    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject] stringByAppendingPathComponent:@"bluetooth.txt"];
    NSString *identfiy = [NSString stringWithFormat:@"%@",peripheral.identifier];
    NSString *name = peripheral.name.length?peripheral.name:@"null";
    NSDictionary *dic  =  @{
                           @"name": name,
                           @"mac": identfiy,
                           @"state": @(false),
                           @"signal":@(false),
                           };
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:StorePerpheral];
    self.reconnect = false;
    self.myPeripheral = peripheral;
    self.myPeripheral.delegate = self;
    [self.myPeripheral discoverServices:nil];
    [self scanOrStop:false];
    NSLog(@"连接成功............%@",peripheral.name);

    [self performSelector:@selector(connectedPeripheralRespnse) withObject:nil afterDelay:0.5];
}

- (void)connectedPeripheralRespnse
{
    if ([self.delegate respondsToSelector:@selector(connectedPeripheral:)]) {
        [self.delegate connectedPeripheral:self.myPeripheral];
    }
}

#pragma mark 连接外设失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (!self.interruptBySelf) {
        self.interruptBySelf = true;
    }
    [self scanOrStop:false];
    NSLog(@"连接失败.................");
    [self performSelector:@selector(realDisconnect) withObject:nil afterDelay:10];
}

#pragma mark 外设断开
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
//    UIAlertView *aler= [[UIAlertView alloc] initWithTitle:@"蓝牙连接断开" message:[NSString stringWithFormat:@"%@:%@",peripheral.name,peripheral.identifier] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [aler show];
    NSLog(@"外设断开..............%@",peripheral.name);
    if (!self.interruptBySelf && self.manager.state == CBCentralManagerStatePoweredOn && self.myPeripheral) {
        [self.manager connectPeripheral:self.myPeripheral options:nil];
        [self searchFilter];
        [self performSelector:@selector(realDisconnect) withObject:nil afterDelay:10];
    }else{
        if ([self.delegate respondsToSelector:@selector(disconnectedPeripheral:)]) {
            [self.delegate disconnectedPeripheral:peripheral];
        }
        self.myPeripheral = nil;
        [self scanOrStop:true];
    }
}

- (void)realDisconnect
{
    if (self.myPeripheral) {
        if (self.myPeripheral.state != CBPeripheralStateConnected) {
            [self.manager cancelPeripheralConnection:self.myPeripheral];
            if ([self.delegate respondsToSelector:@selector(disconnectedPeripheral:)]) {
                [self.delegate disconnectedPeripheral:self.myPeripheral];
            }
            self.myPeripheral = nil;
        }
    }
}

#pragma mark 外设更新名称
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral
{
    NSLog(@"更新外设名称..........%@",peripheral.name);
}

#pragma mark 发现外设服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services) {
        NSLog(@"发现外设服务..........%@",service);
        [self.myPeripheral discoverCharacteristics:nil forService:service];
    }
}

#pragma mark 扫描到指定服务的特征值
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error
{
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"特征值................%@.............%@",[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding],characteristic.UUID);
        NSString *uuid = [[NSString alloc] initWithFormat:@"%@",characteristic.UUID];
        if (characteristic.properties == CBCharacteristicPropertyNotify) {
            [self.myPeripheral setNotifyValue:true forCharacteristic:characteristic];
        }
        else if ([uuid isEqualToString:@"49535343-6DAA-4D02-ABF6-195669ACA69FE"]){
            self.characteristic = characteristic;
        }
        else if ([uuid isEqualToString:@"49535343-8841-43F4-A8D4-ECBE34729BB3"]){
            self.characteristic = characteristic;
        }
    }
}

#pragma mark 监听特征值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"监听特征值..............%@....................%lu",[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding],(unsigned long)characteristic.properties);
}

#pragma mark 特征值更新
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    NSString *deviceMac = [[NSString alloc] initWithFormat:@"%@",peripheral.identifier];
    [self.handlingModel handlingRecevieData:characteristic.value deviceMac:deviceMac fromAddress:nil];
//    [self.handlingModel handlingRecevieData:characteristic.value deviceIdentifiy:deviceMac fromAddress:nil];
}

#pragma mark 特征值写入
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"写入特征值......%@",characteristic.value);
}

#pragma mark 描述写入
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    NSLog(@"写入描述......");
}

#pragma mark 判断两个外设相同
-(BOOL)isPeripheral:(CBPeripheral*)peripheral1 equalPeripheral:(CBPeripheral*)peripheral2 {
    if (peripheral1 == nil || peripheral2 == nil) {
        return NO;
    }
    return  [peripheral1.identifier isEqual: peripheral2.identifier];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
#ifndef __IPHONE_9_0
        return peripheral1.UUID == peripheral2.UUID;
#endif
    } else {
        return [peripheral1.identifier isEqual: peripheral2.identifier] && [peripheral1.name isEqualToString:peripheral2.name];
    }
    
    return NO;
}

@end
