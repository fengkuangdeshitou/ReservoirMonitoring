//
//  UIView+Border.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/12.
//

#import "UIView+Border.h"

@implementation UIView (Border)

- (void)showBorderWithRadius:(CGFloat)radius{
    self.layer.borderColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR].CGColor;
    self.layer.borderWidth = 0.5;
    self.layer.cornerRadius = radius;
}

@end
