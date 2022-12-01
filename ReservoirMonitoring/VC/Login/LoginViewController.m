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

@interface LoginViewController ()<ImageAuthenticationViewDelegate,UITextFieldDelegate>

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
    self.passwordtf.delegate = self;
    [self.loginBtn setTitle:@"Login".localized forState:UIControlStateNormal];
    [self.create setTitle:@"Create account".localized forState:UIControlStateNormal];
    [self.forgot setTitle:@"Forget password".localized forState:UIControlStateNormal];
    self.emailtf.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
    self.passwordtf.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePassword:) name:CHANGE_PASSWORD_NOTIFICATION object:nil];
}

- (void)changePassword:(NSNotification *)notification{
    self.emailtf.text = notification.object;
    self.passwordtf.text = @"";
}

- (IBAction)previewChangeAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    self.passwordtf.secureTextEntry = !sender.selected;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSInteger existedLength = textField.text.length;
    NSInteger selectedLength = range.length;
    NSInteger replaceLength = string.length;
    NSInteger pointLength = existedLength - selectedLength + replaceLength;
    if (pointLength > 20) {
        return NO;
    }else{
        return YES;
    }
}

- (void)onAuthemticationSuccess{
    [Request.shareInstance postUrl:Login params:@{@"userName":self.emailtf.text,@"password":self.passwordtf.text} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        [NSUserDefaults.standardUserDefaults setValue:result[@"data"][@"token"] forKey:@"token"];
        [RMHelper saveTouristsModel:false];
        [self getUserInfo];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (void)getUserInfo{
    [Request.shareInstance getUrl:UserInfo params:@{} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        NSDictionary * data = result[@"data"];
        if (data[@"userType"]){
            NSInteger userType = [data[@"userType"] integerValue];
            [RMHelper setUserType:userType<=1];
        }else{
            [RMHelper setUserType:false];
        }
        [NSUserDefaults.standardUserDefaults setValue:[NSString stringWithFormat:@"%@",data[@"defDevId"]] forKey:CURRENR_DEVID];
        [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESS object:nil];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (IBAction)loginAction:(id)sender{
    if (self.emailtf.text.length == 0) {
        [RMHelper showToast:self.emailtf.placeholder toView:self.view];
        return;
    }
    if (self.passwordtf.text.length == 0) {
        [RMHelper showToast:self.passwordtf.placeholder toView:self.view];
        return;
    }
    if (self.passwordtf.text.length < 6 || self.passwordtf.text.length > 20) {
        [RMHelper showToast:@"Please enter 6-20 digit password" toView:self.view];
        return;
    }
    [self.view endEditing:true];
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

- (IBAction)touristsLoginAction:(id)sender{
    [Request.shareInstance postUrl:VisitorsLogin params:@{} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        [RMHelper saveTouristsModel:true];
        [NSUserDefaults.standardUserDefaults setValue:result[@"data"][@"token"] forKey:@"token"];
        [self getUserInfo];
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
