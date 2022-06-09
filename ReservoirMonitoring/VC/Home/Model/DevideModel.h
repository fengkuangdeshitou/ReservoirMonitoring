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
@property(nonatomic,strong) NSString * selfHelpRate;
/// 1:匹配负载模式 2:TOU模式 3:备电模式 4:离网模式
@property(nonatomic,strong) NSString * workStatus;
/// 0:自检 1:故障 2:空闲 3:待机 4:运行
@property(nonatomic,strong) NSString * deviceStatus;
/// 电网功率方向 精度:0.01 单位:kW
@property(nonatomic,strong) NSString * gridPower; 
/// 电网电量 精度:0.01 单位:kWh
@property(nonatomic,strong) NSString * gridElectricity;
/// 光伏功率 精度:0.01 单位:kW
@property(nonatomic,strong) NSString * solarPower;
/// 光伏电量 精度:0.01 单位:kWh
@property(nonatomic,strong) NSString * solarElectricity;
/// 发电机功率 精度:0.01 单位:kW
@property(nonatomic,strong) NSString * generatorPower;
/// 发电机电量 精度:0.01 单位:kWh
@property(nonatomic,strong) NSString * generatorElectricity;
/// EV功率 精度:0.01 单位:kW
@property(nonatomic,strong) NSString * evPower;
/// EV电量 精度:0.01 单位:kWh
@property(nonatomic,strong) NSString * evElectricity;
/// 一般负载功率 精度:0.01 单位:kW
@property(nonatomic,strong) NSString * nonBackUpPower;
/// 一般负载电量 精度:0.01 单位:kWh
@property(nonatomic,strong) NSString * nonBackUpElectricity;
/// 重要负载功率 精度:0.01 单位:kW
@property(nonatomic,strong) NSString * backUpPower;
/// 重要负载电量 精度:0.01 单位:kWh
@property(nonatomic,strong) NSString * backUpElectricity;
/// 剩余电量百分百
@property(nonatomic,strong) NSString * batterySoc;
/// 剩余电量kWh
@property(nonatomic,strong) NSString * batteryCurrentElectricity;

@property(nonatomic,strong) NSString * name;

@property(nonatomic,strong) NSString * sgSn;

@end

NS_ASSUME_NONNULL_END
