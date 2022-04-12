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


@end

NS_ASSUME_NONNULL_END
