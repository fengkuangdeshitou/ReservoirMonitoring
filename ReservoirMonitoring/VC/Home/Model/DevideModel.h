//
//  DevideModel.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevideModel : NSObject

/// 1:匹配负载模式 2:TOU模式 3:备电模式 4:离网模式
@property(nonatomic,strong) NSString * currentMode;
/// 0:自检 1:故障 2:空闲 3:待机 4:运行
@property(nonatomic,strong) NSString * deviceStatus;
/// Grid流动方向
@property(nonatomic,strong) NSString * gridDirection;
/// Grid
@property(nonatomic,strong) NSString * gridValue;
/// Solar 流动方向
@property(nonatomic,strong) NSString * solarDirection;
/// Solar
@property(nonatomic,strong) NSString * solarValue;
/// generator 流动方向
@property(nonatomic,strong) NSString * generatorDirection;
/// generator
@property(nonatomic,strong) NSString * generatorValue;
/// EV 流动方向
@property(nonatomic,strong) NSString * EVDirection;
/// EV
@property(nonatomic,strong) NSString * EVValue;
/// otherloads 方向
@property(nonatomic,strong) NSString * otherLoadsDirection;
/// otherloads
@property(nonatomic,strong) NSString * otherLoadsValue;
/// Backup loads 方向
@property(nonatomic,strong) NSString * backupLoadsDirection;
/// Backup loads
@property(nonatomic,strong) NSString * backupLoadsValue;
/// 剩余电量百分百
@property(nonatomic,strong) NSString * soc;
/// 剩余电量kWh
@property(nonatomic,strong) NSString * socValue;

@end

NS_ASSUME_NONNULL_END
