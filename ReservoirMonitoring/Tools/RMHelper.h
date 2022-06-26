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
+ (int)getBleDataValue:(NSString *)string;

/// 获取用户类型是否为安装商
+ (BOOL)getUserType;

/// 设置用户类型是否为安装商，默认为NO
/// @param isInstall 是否为安装商
+ (void)setUserType:(BOOL)isInstall;

/// 设置数据请求来源是否为蓝牙，默认http
/// @param isBluetooth 是否蓝牙
+ (void)setLoadDataForBluetooth:(BOOL)isBluetooth;

/// 获取数据来源是否为蓝牙
+ (BOOL)getLoadDataForBluetooth;


@end

NS_ASSUME_NONNULL_END
