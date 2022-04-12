//
//  UITextField+PlaceholderColor.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/13.
//

#import "UITextField+PlaceholderColor.h"
#import <objc/runtime.h>

static const void *placeholderKey = &placeholderKey;

@implementation UITextField (PlaceholderColor)

- (void)setPlaceholderColor:(UIColor *)placeholderColor{
    if (self.placeholder.length > 0) {
        NSMutableAttributedString * placeholder = [[NSMutableAttributedString alloc] initWithString:self.placeholder];
        [placeholder addAttributes:@{NSForegroundColorAttributeName:placeholderColor} range:NSMakeRange(0, placeholder.length)];
        self.attributedPlaceholder = placeholder;
    }
}

@end
