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

@end

NS_ASSUME_NONNULL_END
