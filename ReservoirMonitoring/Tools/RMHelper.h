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


@end

NS_ASSUME_NONNULL_END
