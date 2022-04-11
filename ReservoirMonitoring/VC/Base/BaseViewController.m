//
//  BaseViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/11.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (UITextField.appearance.placeholder.length>0) {
        NSMutableAttributedString * placeholder = [[NSMutableAttributedString alloc] initWithString:UITextField.appearance.placeholder];
        [placeholder addAttributes:@{NSFontAttributeName:[UIColor colorWithHexString:@"#747474"]} range:NSMakeRange(0, placeholder.length)];
        UITextField.appearance.attributedPlaceholder = placeholder;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
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
