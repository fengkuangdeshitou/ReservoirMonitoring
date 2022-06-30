//
//  SetPasswordViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/12.
//

#import "SetPasswordViewController.h"

@interface SetPasswordViewController ()

@property(nonatomic,weak)IBOutlet UIButton * submit;
@property(nonatomic,weak)IBOutlet UITextField * password;
@property(nonatomic,weak)IBOutlet UITextField * confirm;
@property(nonatomic,weak)IBOutlet UILabel * email;
@property(nonatomic,weak)IBOutlet UILabel * pass;

@end

@implementation SetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.email.text = @"1.Verify Email".localized;
    self.pass.text = @"2.New password".localized;
    [self.submit setTitle:@"Submit".localized forState:UIControlStateNormal];
    [self.submit showBorderWithRadius:25];
    self.password.placeholder = @"Please set a 6-20 digit password".localized;
    self.confirm.placeholder = @"Please confirm password".localized;
    self.password.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
    self.confirm.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
}

- (IBAction)submitAction:(id)sender{
    if (self.password.text.length == 0) {
        [RMHelper showToast:self.password.placeholder toView:self.view];
        return;
    }
    if (self.confirm.text.length == 0) {
        [RMHelper showToast:self.confirm.placeholder toView:self.view];
        return;
    }
    if (![self.password.text isEqualToString:self.confirm.text]) {
        [RMHelper showToast:@"Inconsistent passwords" toView:self.view];
        return;
    }
    [Request.shareInstance postUrl:ResetPwd params:@{@"userName":self.userName,@"password":self.password.text,@"code":self.code,@"uuid":self.uuid} progress:^(float progress) {
        [self.navigationController popToRootViewControllerAnimated:true];
    } success:^(NSDictionary * _Nonnull result) {
        
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
