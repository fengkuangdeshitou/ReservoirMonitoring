//
//  NavigationViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/11.
//

#import "NavigationViewController.h"

@interface UINavigationController (UINavigationControllerNeedShouldPopItem)
- (BOOL) navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item;
@end

@implementation UINavigationController (UINavigationControllerNeedShouldPopItem)
@end

@interface NavigationViewController ()<UINavigationBarDelegate>

@end

@implementation NavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationBar.translucent = NO;
    self.navigationBar.tintColor = UIColor.whiteColor;
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.backgroundColor = [UIColor colorWithHexString:@"#1E1E1E"];
    self.navigationBar.barTintColor = [UIColor colorWithHexString:@"#1E1E1E"];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#1E1E1E"];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:UIColor.whiteColor,NSFontAttributeName:[UIFont systemFontOfSize:18 weight:UIFontWeightMedium]};
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance * appearance = [[UINavigationBarAppearance alloc] init];
        appearance.backgroundColor = [UIColor colorWithHexString:@"#1E1E1E"];
        appearance.backgroundImage = [UIImage new];
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName:UIColor.whiteColor,NSFontAttributeName:[UIFont systemFontOfSize:18 weight:UIFontWeightMedium]};
        self.navigationBar.standardAppearance = appearance;
        self.navigationBar.compactAppearance = appearance;
        self.navigationBar.scrollEdgeAppearance = appearance;
    } else {
        // Fallback on earlier versions

    }
    
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item{
    if ([self.topViewController isKindOfClass:NSClassFromString(@"InverterViewController")]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_RESS_NOTIFICATION object:nil];
        return false;
    }else{
        return [super navigationBar:navigationBar shouldPopItem:item];
    }
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
