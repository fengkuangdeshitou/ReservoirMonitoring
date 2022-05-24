//
//  LoginViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/11.
//

#import "LoginViewController.h"
#import "ImageAuthenticationView.h"
#import "Register/RegisterViewController.h"
#import "ForgotViewController.h"

@interface LoginViewController ()<ImageAuthenticationViewDelegate>

@property(nonatomic,weak)IBOutlet UIButton * loginBtn;
@property(nonatomic,weak)IBOutlet UILabel * email;
@property(nonatomic,weak)IBOutlet UILabel * password;
@property(nonatomic,weak)IBOutlet UIButton * create;
@property(nonatomic,weak)IBOutlet UIButton * forgot;
@property(nonatomic,weak)IBOutlet UITextField * emailtf;
@property(nonatomic,weak)IBOutlet UITextField * passwordtf;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.loginBtn showBorderWithRadius:25];
    self.email.text = @"Email".localized;
    self.password.text = @"Password".localized;
    self.emailtf.placeholder = @"Please input your Email".localized;
    self.passwordtf.placeholder = @"Please input your Password".localized;
    [self.loginBtn setTitle:@"Login".localized forState:UIControlStateNormal];
    [self.create setTitle:@"Create account".localized forState:UIControlStateNormal];
    [self.forgot setTitle:@"Forget password".localized forState:UIControlStateNormal];
    self.emailtf.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
    self.passwordtf.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];

}

- (IBAction)previewChangeAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    self.passwordtf.secureTextEntry = !sender.selected;
}

- (void)onAuthemticationSuccess{
    [Request.shareInstance postUrl:Login params:@{@"userName":self.emailtf.text,@"password":self.passwordtf.text} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        [NSUserDefaults.standardUserDefaults setValue:result[@"data"][@"token"] forKey:@"token"];
        [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESS object:nil];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (IBAction)loginAction:(id)sender{
    if (self.email.text.length == 0) {
        [RMHelper showToast:self.emailtf.placeholder toView:self.view];
        return;
    }
    if (self.passwordtf.text.length == 0) {
        [RMHelper showToast:self.passwordtf.placeholder toView:self.view];
        return;
    }
    [ImageAuthenticationView showImageAuthemticationWithDelegate:self];
}

- (IBAction)registerAction:(id)sender{
    RegisterViewController * regist = [[RegisterViewController alloc] init];
    regist.registerSuccess = ^(NSString * _Nonnull username, NSString * _Nonnull password) {
        self.emailtf.text = username;
        self.passwordtf.text = password;
    };
    regist.title = @"Create account".localized;
    [self.navigationController pushViewController:regist animated:true];
}

- (IBAction)forgotAction:(id)sender{
    ForgotViewController * forgot = [[ForgotViewController alloc] init];
    forgot.title = @"Retrieve password".localized;
    [self.navigationController pushViewController:forgot animated:true];
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
