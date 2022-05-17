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


/**主题颜色*/
extern NSString * const COLOR_MAIN_COLOR;
/**背景色*/
extern NSString * const COLOR_BACK_COLOR;
/**输入框placehodel颜色*/
extern NSString * const COLOR_PLACEHOLDER_COLOR;

/**运行模式高度改变通知*/
extern NSString * const TIME_TABLEVIEW_HEIGHT_CHANGE;
/**登录成功*/
extern NSString * const LOGIN_SUCCESS;
/**退出登录*/
extern NSString * const LOG_OUT;

@end

NS_ASSUME_NONNULL_END
