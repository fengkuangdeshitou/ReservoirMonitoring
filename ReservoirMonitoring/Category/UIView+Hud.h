//
//  UIView+Hud.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/7/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Hud)

- (void)showHUDToast:(NSString *)toast;

- (void)hiddenHUD;

@end

NS_ASSUME_NONNULL_END
