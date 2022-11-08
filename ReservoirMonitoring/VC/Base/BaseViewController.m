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

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.view endEditing:true];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (@available(iOS 15.0, *)) {
        UITableView.appearance.sectionHeaderTopPadding = 0;
    } else {
        // Fallback on earlier versions
    }
    UITextField.appearance.tintColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
    UITextField.appearance.textColor = UIColor.whiteColor;
    if (UITextField.appearance.placeholder.length>0) {
        NSMutableAttributedString * placeholder = [[NSMutableAttributedString alloc] initWithString:UITextField.appearance.placeholder];
        [placeholder addAttributes:@{NSFontAttributeName:[UIColor colorWithHexString:@"#747474"]} range:NSMakeRange(0, placeholder.length)];
        UITextField.appearance.attributedPlaceholder = placeholder;
    }
}

- (UIRefreshControl *)refreshController{
    if (!_refreshController) {
        _refreshController = [[UIRefreshControl alloc] init];
        _refreshController.tintColor = UIColor.whiteColor;
    }
    return _refreshController;
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
