//
//  UIView+Hud.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/7/11.
//

#import "UIView+Hud.h"
@import MBProgressHUD;

@interface UIView()

@property(nonatomic,strong)MBProgressHUD * hud;

@end

@implementation UIView (Hud)

static NSString * const hudKey = @"hudKey";

- (void)setHud:(MBProgressHUD *)hud{
    objc_setAssociatedObject(self, &hudKey, hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MBProgressHUD *)hud{
    return objc_getAssociatedObject(self, &hudKey);
}

- (void)showHUDToast:(NSString *)toast{
    if (!self.hud) {
        self.hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    }
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.contentColor = [UIColor whiteColor];
    self.hud.label.text = toast;
    self.hud.label.textColor = UIColor.whiteColor;
    self.hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    self.hud.bezelView.backgroundColor = [UIColor colorWithHexString:@"#181818"];
    self.hud.removeFromSuperViewOnHide = YES;
}

- (void)hiddenHUD{
    [self.hud hideAnimated:true];
    self.hud = nil;
}

@end
