//
//  UITextView+Placeholder.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/11/3.
//

#import "UITextView+Placeholder.h"

@implementation UITextView (Placeholder)

- (void)setPlaceholder:(NSString *)placeholder{
    UILabel *placeHolderStr = [[UILabel alloc] init];
    placeHolderStr.text = placeholder;
    placeHolderStr.numberOfLines = 0;
    placeHolderStr.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    placeHolderStr.font = [UIFont systemFontOfSize:14];
    [placeHolderStr sizeToFit];
    [self addSubview:placeHolderStr];
    placeHolderStr.font = self.font;
    [self setValue:placeHolderStr forKey:@"_placeholderLabel"];
}

@end
