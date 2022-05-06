//
//  AddAddressViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/5/6.
//

#import "AddAddressViewController.h"

@interface AddAddressViewController ()

@property(nonatomic,weak)IBOutlet UILabel * address;
@property(nonatomic,weak)IBOutlet UITextField * countries;
@property(nonatomic,weak)IBOutlet UITextField * province;
@property(nonatomic,weak)IBOutlet UITextField * code;
@property(nonatomic,weak)IBOutlet UIButton * time;
@property(nonatomic,weak)IBOutlet UILabel * link;
@property(nonatomic,weak)IBOutlet UITextField * email;
@property(nonatomic,weak)IBOutlet UIButton * confirm;

@end

@implementation AddAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.address.text = @"Device location".localized;
    self.countries.placeholder = @"Country".localized;
    self.province.placeholder = @"State".localized;
    self.code.placeholder = @"Zip code".localized;
    [self.time setTitle:@"Time zone".localized forState:UIControlStateNormal];
    self.link.text = @"Link Email".localized;
    self.email.placeholder = @"Enter Email".localized;
    [self.confirm setTitle:@"Confirm".localized forState:UIControlStateNormal];
    [self.confirm showBorderWithRadius:25];
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
