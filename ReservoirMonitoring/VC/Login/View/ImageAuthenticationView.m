//
//  ImageAuthenticationView.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/12.
//

#import "ImageAuthenticationView.h"
@import WMZCode;

@interface ImageAuthenticationView ()

@property(nonatomic,weak)IBOutlet UIView * contentView;
@property(nonatomic,weak)IBOutlet UILabel * titleLabel;
@property(nonatomic,weak)id<ImageAuthenticationViewDelegate> delegale;

@end

@implementation ImageAuthenticationView

+ (void)showImageAuthemticationWithDelegate:(id<ImageAuthenticationViewDelegate>)delegage{
    ImageAuthenticationView * view = [[ImageAuthenticationView alloc] initWithDelegate:delegage];
    [view show];
}

- (instancetype)initWithDelegate:(id<ImageAuthenticationViewDelegate>)delegate
{
    self = [super init];
    if (self) {
        self = [NSBundle.mainBundle loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil].lastObject;
        self.frame = UIScreen.mainScreen.bounds;
        self.delegale = delegate;
        self.titleLabel.text = @"Slide the bar to complete the picture.".localized;
        [UIApplication.sharedApplication.keyWindow addSubview:self];
        WMZCodeView *codeView = [[WMZCodeView shareInstance] addCodeViewWithType:CodeTypeImage withImageName:@"A" witgFrame:CGRectMake(0, 30, 345, 200)  withBlock:^(BOOL success) {
            if (success) {
                if (self.delegale && [self.delegale respondsToSelector:@selector(onAuthemticationSuccess)]) {
                    [self.delegale onAuthemticationSuccess];
                }
                [self dismiss];
            }
        }];
        [self.contentView addSubview: codeView];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
