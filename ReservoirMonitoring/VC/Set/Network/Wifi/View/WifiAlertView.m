//
//  WifiAlertView.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/18.
//

#import "WifiAlertView.h"

@interface WifiAlertView ()

@property(nonatomic,weak)IBOutlet UILabel * titleLabel;
@property(nonatomic,weak)IBOutlet UITextField * wifiName;
@property(nonatomic,weak)IBOutlet UITextField * password;
@property(nonatomic,weak)IBOutlet NSLayoutConstraint * wifiNameHeight;
@property(nonatomic,weak)IBOutlet UIButton * cancel;
@property(nonatomic,weak)IBOutlet UIButton * confirm;

@property(nonatomic,copy)void(^completion)(NSString * wifiName,NSString * password);

@end

@implementation WifiAlertView

+ (void)showWifiAlertViewWithTitle:(NSString *)title
                      showWifiName:(BOOL)showWifiName
                        completion:(void (^)(NSString * wifiName,NSString * password))completion{
    WifiAlertView * alert = [[NSBundle.mainBundle loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil]lastObject];
    alert.frame = UIScreen.mainScreen.bounds;
    alert.alpha = 0;
    [UIApplication.sharedApplication.keyWindow addSubview:alert];
    alert.titleLabel.text = title;
    if (!showWifiName) {
        alert.wifiNameHeight.constant = 0;
    }
    alert.wifiName.placeholder = @"Please input Wi-Fi name".localized;
    alert.wifiName.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
    alert.password.placeholder = @"Please input Wi-Fi password".localized;
    alert.password.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
    [alert.cancel setTitle:@"Cancel".localized forState:UIControlStateNormal];
    [alert.confirm setTitle:@"Confirm".localized forState:UIControlStateNormal];
    alert.cancel.layer.cornerRadius = 20;
    alert.cancel.layer.borderColor = [UIColor colorWithHexString:@"#999999"].CGColor;
    alert.cancel.layer.borderWidth = 0.5;
    alert.confirm.layer.cornerRadius = 20;
    alert.confirm.layer.borderColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR].CGColor;
    alert.confirm.layer.borderWidth = 0.5;
    alert.completion = completion;
    [alert show];
}

- (IBAction)previewChangeAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    self.password.secureTextEntry = !sender.selected;
}

- (IBAction)submitAction{
    if (self.completion) {
        self.completion(self.wifiName.text,self.password.text);
    }
    [self dismiss];
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
