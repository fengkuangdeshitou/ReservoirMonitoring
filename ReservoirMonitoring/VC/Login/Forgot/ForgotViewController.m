//
//  ForgotViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/12.
//

#import "ForgotViewController.h"
#import "ImageAuthenticationView.h"
#import "SetPasswordViewController.h"

@interface ForgotViewController ()<ImageAuthenticationViewDelegate>

@property(nonatomic,weak)IBOutlet UIButton * next;
@property(nonatomic,weak)IBOutlet UIButton * codeButton;
@property(nonatomic,weak)IBOutlet UITextField * password;
@property(nonatomic,weak)IBOutlet UITextField * code;
@property(nonatomic,weak)IBOutlet UILabel * email;
@property(nonatomic,weak)IBOutlet UILabel * pass;

@end

@implementation ForgotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.email.text = @"1.Verify Email".localized;
    self.pass.text = @"2.New password".localized;
    [self.next setTitle:@"Next".localized forState:UIControlStateNormal];
    [self.next showBorderWithRadius:25];
    self.password.placeholder = @"Please enter registration Email".localized;
    self.code.placeholder = @"Verification code".localized;
    [self.codeButton setTitle:@"Send code".localized forState:UIControlStateNormal];
    self.password.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
    self.code.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
}

- (IBAction)nextAction:(id)sender{
    [ImageAuthenticationView showImageAuthemticationWithDelegate:self];
}

- (void)onAuthemticationSuccess{
    SetPasswordViewController * set = [[SetPasswordViewController alloc] init];
    set.title = @"Set a new password";
    [self.navigationController pushViewController:set animated:true];
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
