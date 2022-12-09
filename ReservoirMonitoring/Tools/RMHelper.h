//
//  RMHelper.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RMHelper : NSObject

+ (UIViewController *)getCurrentVC;

+ (void)showToast:(NSString *)toast toView:(UIView *)view;

+ (void)saveUserInfo:(NSDictionary *)userInfo;

/// 首页方向
/// @param string 0 默认 <0 逆向 >0 正向
+ (int)getBleDataValue:(CGFloat)string min:(NSInteger)min max:(NSInteger)max;

/// 获取用户类型是否为安装商
+ (BOOL)getUserType;

/// 设置用户类型是否为安装商
/// @param isInstall 是否为安装商
+ (void)setUserType:(BOOL)isInstall;

/// 设置数据请求来源是否为蓝牙，默认http
/// @param isBluetooth 是否蓝牙
+ (void)setLoadDataForBluetooth:(BOOL)isBluetooth;

/// 获取数据来源是否为蓝牙
+ (BOOL)getLoadDataForBluetooth;

/// 判断两个时间段是否有交集
/// @param startTime1 第一个开始时间
/// @param startTime2 第一个结束时间
/// @param endTime1 第二个开始时间
/// @param endTime2 第二个结束时间
+ (BOOL)isBetweenStartTime1:(NSString *)startTime1
                 startTime2:(NSString *)startTime2
                   endTime1:(NSString *)endTime1
                   endTime2:(NSString *)endTime2;

+ (BOOL)hasRepeatedTimeForArray:(NSArray *)timeArray;

+ (void)saveTouristsModel:(BOOL)model;
/// 是否游客模式
+ (BOOL)isTouristsModel;
/// 10进制转2进制
+ (NSString *)toBinarySystemWithDecimalSystem:(int)num length:(int)length;

@end

NS_ASSUME_NONNULL_END
