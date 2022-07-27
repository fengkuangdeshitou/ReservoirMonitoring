//
//  GlobelDescAlertView.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/5/8.
//

#import "GlobelDescAlertView.h"

@interface GlobelDescAlertView ()

@property(nonatomic,weak)IBOutlet UILabel * titleLabel;
@property(nonatomic,weak)IBOutlet UILabel * descLabel;
@property(nonatomic,weak)IBOutlet UIButton * doneButton;
@property(nonatomic,weak)IBOutlet NSLayoutConstraint * doneButtonWidth;
@property(nonatomic,copy) void(^completion)(void);

@end

@implementation GlobelDescAlertView

+ (void)showAlertViewWithTitle:(NSString *)title
                          desc:(NSString *)desc
                      btnTitle:(nullable NSString *)btnTitle
                    completion:(void(^)(void))completion{
    GlobelDescAlertView * alertView = [[GlobelDescAlertView alloc] initWithTitle:title desc:desc btnTitle:btnTitle completion:completion];
    [alertView show];
}


- (instancetype)initWithTitle:(NSString *)title
                         desc:(NSString *)desc
                     btnTitle:(nullable NSString *)btnTitle
                   completion:(void(^)(void))completion
{
    self = [super init];
    if (self) {
        self = [[NSBundle.mainBundle loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
        self.frame = UIScreen.mainScreen.bounds;
        [UIApplication.sharedApplication.keyWindow addSubview:self];
        self.alpha = 0;
        self.completion = completion;
        self.titleLabel.text = title;
        self.descLabel.text = desc;
        if (btnTitle) {
            [self.doneButton setTitle:btnTitle forState:UIControlStateNormal];
        }else{
            if ([title isEqualToString:@"Ticket received".localized]) {
                [self.doneButton setTitle:@"Acknowledge".localized forState:UIControlStateNormal];
            }else{
                [self.doneButton setTitle:@"Confirm".localized forState:UIControlStateNormal];
            }
        }
        CGFloat width = [self.doneButton.titleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size.width;
        self.doneButtonWidth.constant = width+44;
        [self.doneButton showBorderWithRadius:20];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)show{
    [UIView animateWithDuration:0.1 animations:^{
            self.alpha = 1;
    }];
}

- (IBAction)dismiss{
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
}

- (IBAction)doneAction:(UIButton *)sender{
    if (self.completion) {
        self.completion();
    }
    [self dismiss];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
