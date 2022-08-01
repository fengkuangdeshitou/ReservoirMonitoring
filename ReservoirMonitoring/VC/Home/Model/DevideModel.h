//
//  DevideModel.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevideModel : NSObject

@property(nonatomic,strong) NSString * deviceId;

/// 状态（1-并网 2-离网）
@property(nonatomic,strong) NSString * status;
/// 日家庭能源独立率 单位 %
@property(nonatomic,assign) CGFloat selfHelpRate;
/// 1:匹配负载模式 2:TOU模式 3:备电模式 4:离网模式
@property(nonatomic,strong) NSString * workStatus;
/// 0:自检 1:故障 2:空闲 3:待机 4:运行
@property(nonatomic,strong) NSString * deviceStatus;
/// 空值 offline 1:故障 其余正常
@property(nonatomic,strong) NSString * systemStatus;
/// 释放电量值
@property(nonatomic,assign) CGFloat gridElectricityFrom;
/// 充电电量值
@property(nonatomic,assign) CGFloat gridElectricityTo;
/// 电网功率方向 精度:0.01 单位:kW
@property(nonatomic,assign) CGFloat gridPower;
/// 电网电量 精度:0.01 单位:kWh
@property(nonatomic,assign) CGFloat gridElectricity;
/// 电网放电
@property(nonatomic,assign) CGFloat gridElectricityFd;
/// 电网充电
@property(nonatomic,assign) CGFloat gridElectricityQd;
/// 光伏功率 精度:0.01 单位:kW
@property(nonatomic,assign) CGFloat solarPower;
/// 光伏电量 精度:0.01 单位:kWh
@property(nonatomic,assign) CGFloat solarElectricity;
/// 发电机功率 精度:0.01 单位:kW
@property(nonatomic,assign) CGFloat generatorPower;
/// 发电机电量 精度:0.01 单位:kWh
@property(nonatomic,assign) CGFloat generatorElectricity;
/// EV功率 精度:0.01 单位:kW
@property(nonatomic,assign) CGFloat evPower;
/// EV电量 精度:0.01 单位:kWh
@property(nonatomic,assign) CGFloat evElectricity;
/// 一般负载功率 精度:0.01 单位:kW
@property(nonatomic,assign) CGFloat nonBackUpPower;
/// 一般负载电量 精度:0.01 单位:kWh
@property(nonatomic,assign) CGFloat nonBackUpElectricity;
/// 是否隐藏
@property(nonatomic,copy) NSString * backUpType;
/// 重要负载功率 精度:0.01 单位:kW
@property(nonatomic,assign) CGFloat backUpPower;
/// 重要负载电量 精度:0.01 单位:kWh
@property(nonatomic,assign) CGFloat backUpElectricity;
/// 剩余电量百分百
@property(nonatomic,strong) NSString * batterySoc;
/// 剩余电量kWh
@property(nonatomic,strong) NSString * batteryCurrentElectricity;

@property(nonatomic,strong) NSString * name;

@property(nonatomic,strong) NSString * sgSn;

@property(nonatomic,strong) NSString * rtuSn;

@property(nonatomic,strong) NSString * lastConnect;

@property(nonatomic,assign) BOOL isConnected;

@property(nonatomic,strong) NSString * isOnline;

@property(nonatomic,assign) CGFloat treeNum;

@property(nonatomic,assign) CGFloat coal;

@property(nonatomic,strong) NSString * off_ON_Grid_Hint;

@property(nonatomic,strong) NSDictionary * weather;

@end

NS_ASSUME_NONNULL_END
