//
//  BleManager.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/18.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BleManagerDelegate <NSObject>

/// 读取蓝牙回调
/// @param cmd 通讯命令
- (void)bluetoothDidReceivedCMD:(NSString *)cmd array:(NSArray *)array;

/// 蓝牙状态
/// @param central 蓝牙状态
- (void)bluetoothDidUpdateState:(CBCentralManager *)central;

/// 蓝牙断开
/// @param peripheral 外设
- (void)bluetoothDidDisconnectPeripheral:(CBPeripheral *)peripheral;

/// 蓝牙发现外设
/// @param peripheral 外设
- (void)bluetoothdidDiscoverPeripheral:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI;

/// 蓝牙连接外设成功
/// @param peripheral 外设
- (void)bluetoothDidConnectPeripheral:(CBPeripheral *)peripheral;

@end

@interface BleManager : NSObject

+ (instancetype)shareInstance;

/// 是否自动连接,默认YES
@property(nonatomic,assign)BOOL isAutoConnect;
/// 蓝牙名称
@property(nonatomic,copy)NSString * bluetoothName;
/// 是否记录数据
@property(nonatomic,assign)BOOL isRecordingData;

@property(nonatomic,weak)id<BleManagerDelegate>delegate;

- (void)startScanning;

- (void)stopScan;

- (void)connectPeripheral:(CBPeripheral *)peripheral;
/// 断开连接
- (void)disconnectPeripheral;

/// 蓝牙获取车辆信息
/// @param cmd 通讯命令 0x11 速度 0x12 最大速度 0x13 平均速度 0x14 骑行公里数 0x15 骑行时间 0x16 剩余公里数 0x17 总路程 0x1A 电池电量
- (void)readValueWithCMD:(Byte)cmd;

/// 向车辆写入信息
/// @param cmd 命令
/// @param valueByte value
- (void)writeValueWithCMD:(Byte)cmd value:(Byte)valueByte;


/// 读取指令
/// @param string 开始指令
/// @param count 读取位数
- (void)readWithCMDString:(NSString *)string count:(int)count;

/// 写入多个指令
/// @param string 开始指令
/// @param array 值
- (void)writeWithCMDString:(NSString *)string array:(NSArray *)array;

/// 写入单个指令
/// @param string 指令
/// @param value 值
- (void)writeWithCMDString:(NSString *)string string:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
