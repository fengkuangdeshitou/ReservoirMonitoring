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

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.loginBtn showBorderWithRadius:25];
}

- (IBAction)loginAction:(id)sender{
    [ImageAuthenticationView showImageAuthemticationWithDelegate:self];
}

- (IBAction)registerAction:(id)sender{
    RegisterViewController * regist = [[RegisterViewController alloc] init];
    regist.title = @"New user registration".localized;
    [self.navigationController pushViewController:regist animated:true];
}

- (IBAction)forgotAction:(id)sender{
    ForgotViewController * forgot = [[ForgotViewController alloc] init];
    forgot.title = @"Forgot Password";
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
