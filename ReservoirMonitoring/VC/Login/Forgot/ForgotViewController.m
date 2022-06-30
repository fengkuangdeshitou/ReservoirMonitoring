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
@property(nonatomic,assign)NSInteger time;
@property(nonatomic,strong)NSTimer * timer;
@property(nonatomic,strong)NSString * uuid;

@end

@implementation ForgotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.time = 60;
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

- (IBAction)sendCode:(id)sender{
    if (self.password.text.length == 0) {
        [RMHelper showToast:self.password.placeholder toView:self.view];
        return;
    }
    [ImageAuthenticationView showImageAuthemticationWithDelegate:self];
}

- (IBAction)nextAction:(id)sender{
    if (self.password.text.length == 0) {
        [RMHelper showToast:self.password.placeholder toView:self.view];
        return;
    }
    if (self.uuid == nil) {
        [RMHelper showToast:@"Please get verification code".localized toView:self.view];
        return;
    }
    SetPasswordViewController * set = [[SetPasswordViewController alloc] init];
    set.uuid = self.uuid;
    set.code = self.code.text;
    set.userName = self.password.text;
    set.title = self.title.localized;
    [self.navigationController pushViewController:set animated:true];
}

- (void)onAuthemticationSuccess{
    [Request.shareInstance postUrl:EmailCode params:@{@"type":@"2",@"email":self.password.text} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:true block:^(NSTimer * _Nonnull timer) {
            self.uuid = [NSString stringWithFormat:@"%@",result[@"data"]];
                self.time--;
                if (self.time == 0) {
                    self.time = 60;
                    [timer invalidate];
                    self.codeButton.userInteractionEnabled = true;
                    [self.codeButton setTitle:@"Send code".localized forState:UIControlStateNormal];
                }else{
                    self.codeButton.userInteractionEnabled = false;
                    [self.codeButton setTitle:[NSString stringWithFormat:@"%ld",self.time] forState:UIControlStateNormal];
                }
            }];
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
