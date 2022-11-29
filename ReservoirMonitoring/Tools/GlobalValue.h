//
//  GlobalValue.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define StatusBarHeight   [UIApplication sharedApplication].statusBarFrame.size.height
#define NavagationHeight (StatusBarHeight + NavagationBarHeight)
#define TabbarHeight (StatusBarHeight == 20 ? 49 : (49+34))
#define SCREEN_WIDTH    [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT    [[UIScreen mainScreen] bounds].size.height

@interface GlobalValue : NSObject

extern CGFloat const NavagationBarHeight;
/**设备安装记录*/
extern NSString * const DEVICEINSTALLIMG;


/**主题颜色*/
extern NSString * const COLOR_MAIN_COLOR;
/**背景色*/
extern NSString * const COLOR_BACK_COLOR;
/**输入框placehodel颜色*/
extern NSString * const COLOR_PLACEHOLDER_COLOR;
/**游客模式背景颜色*/
extern NSString * const COLOR_TOURISTS_COLOR;
/**蓝牙CMD*/
extern NSString * const BLE_CMD;
/**当前设备id*/
extern NSString * const CURRENR_DEVID;

/**运行模式高度改变通知*/
extern NSString * const TIME_TABLEVIEW_HEIGHT_CHANGE;
/**切换设备通知*/
extern NSString * const SWITCH_DEVICE_NOTIFICATION;
/**是否蓝牙加载数据通知*/
extern NSString * const DATA_TYPE_CHANGE_NOTIFICATION;
/**登录成功*/
extern NSString * const LOGIN_SUCCESS;
/**退出登录*/
extern NSString * const LOG_OUT;
/**修改密码*/
extern NSString * const CHANGE_PASSWORD_NOTIFICATION;
/**切换模式清除*/
extern NSString * const CLEAR_NOTIFICATION;
/**添加设备成功*/
extern NSString * const ADD_DEVICE_NOTIFICATION;
/**RESS设置成功*/
extern NSString * const UPDATE_RESS_NOTIFICATION;
/**通知详情更新*/
extern NSString * const UPDATE_MESSAGEDETAIL_NOTIFICATION;

@end

NS_ASSUME_NONNULL_END
