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

@end

@implementation SetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.submit showBorderWithRadius:25];
    self.password.placeholderColor = [UIColor colorWithHexString:@"#A3A3A3"];
    self.confirm.placeholderColor = [UIColor colorWithHexString:@"#A3A3A3"];
    
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
