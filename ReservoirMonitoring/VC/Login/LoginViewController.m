//
//  LoginViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/11.
//

#import "LoginViewController.h"
@import WMZCode;

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)loginAction:(id)sender{
    WMZCodeView *codeView = [[WMZCodeView shareInstance] addCodeViewWithType:CodeTypeImage withImageName:@"A" witgFrame:CGRectMake(0, 50, 300, 50)  withBlock:^(BOOL success) {
            if (success) {
                NSLog(@"成功");
            }
    }];
    [self.view addSubview: codeView];
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
