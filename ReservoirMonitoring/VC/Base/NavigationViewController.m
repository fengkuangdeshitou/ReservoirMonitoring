//
//  NavigationViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/11.
//

#import "NavigationViewController.h"

@interface NavigationViewController ()

@end

@implementation NavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationBar.translucent = NO;
    self.navigationBar.tintColor = UIColor.whiteColor;
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.backgroundColor = [UIColor colorWithHexString:COLOR_BACK_COLOR];
    self.navigationBar.barTintColor = [UIColor colorWithHexString:COLOR_BACK_COLOR];
//    if (@available(iOS 13.0, *)) {
//        UINavigationBarAppearance * appearance = [[UINavigationBarAppearance alloc] init];
//        appearance.backgroundColor = [UIColor colorWithHexString:COLOR_BACK_COLOR];
//        self.navigationItem.standardAppearance = appearance;
//        self.navigationItem.compactAppearance = appearance;
//        self.navigationItem.scrollEdgeAppearance = appearance;
//    } else {
//        // Fallback on earlier versions
//
//    }
    
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
