//
//  WriteOffViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/8/29.
//

#import "WriteOffViewController.h"
#import "WriteOffDescViewController.h"

@interface WriteOffViewController ()

@property(nonatomic,weak)IBOutlet UIButton * cancelImmediately;
@property(nonatomic,weak)IBOutlet UIButton * statusBtn;

@end

@implementation WriteOffViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.cancelImmediately showBorderWithRadius:25];
}

- (IBAction)statusAction:(UIButton *)sender{
    sender.selected = !sender.selected;
}

- (IBAction)protocolAction:(id)sender{
    WriteOffDescViewController * desc = [[WriteOffDescViewController alloc] init];
    desc.title = @"Notice for cancellation";
    [self.navigationController pushViewController:desc animated:true];
}

- (IBAction)submitAction:(id)sender{
    if (!self.statusBtn.selected) {
        [RMHelper showToast:@"Please read the Notice for account cancellation" toView:self.view];
        return;
    }
    [Request.shareInstance getUrl:LogOff params:@{} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        [RMHelper showToast:result[@"message"] toView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [BleManager.shareInstance disconnectPeripheral];
            [NSUserDefaults.standardUserDefaults removeObjectForKey:@"token"];
            [[NSNotificationCenter defaultCenter] postNotificationName:LOG_OUT object:nil];
        });
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
