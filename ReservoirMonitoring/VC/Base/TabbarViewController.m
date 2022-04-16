//
//  TabbarViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/11.
//

#import "TabbarViewController.h"
#import "HomeViewController.h"
#import "NavigationViewController.h"
#import "DataViewController.h"
#import "SetViewController.h"

@interface TabbarViewController ()

@end

@implementation TabbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 设置 TabBarItemTestAttributes 的颜色。
    [self setUpTabBarItemTextAttributes];
    
    // 设置子控制器
    [self setUpChildViewController];
}

/**
 *  tabBarItem 的选中和不选中文字属性
 */
- (void)setUpTabBarItemTextAttributes{
    
    // 普通状态下的文字属性
    NSMutableDictionary *normalAttrs = [NSMutableDictionary dictionary];
    normalAttrs[NSForegroundColorAttributeName] = [UIColor colorWithHexString:@"#999999"];
    
    // 选中状态下的文字属性
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    selectedAttrs[NSForegroundColorAttributeName] = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
    
    // 设置文字属性
    UITabBarItem *tabBar = [UITabBarItem appearance];
    [tabBar setTitleTextAttributes:normalAttrs forState:UIControlStateNormal];
    
    [tabBar setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
        
    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttrs;
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs;
        appearance.shadowColor = [UIColor colorWithHexString:@"#2E2E2E"];
        appearance.backgroundColor = [UIColor colorWithHexString:COLOR_BACK_COLOR];
        [self.tabBar setStandardAppearance:appearance];
    }else{
        self.tabBar.shadowImage = [UIImage new];
        self.tabBar.backgroundImage = [UIImage new];
    }
    
}

/**
 *  添加子控制器，我这里值添加了4个，没有占位自控制器
 */
- (void)setUpChildViewController{
    
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    [UITabBar appearance].translucent = NO;
    
    [self addOneChildViewController:[[NavigationViewController alloc]initWithRootViewController:[[HomeViewController alloc]init]]
                          WithTitle:@"Home".localized
                          imageName:@"tabbar_home_normal"
                  selectedImageName:@"tabbar_home_active"];
    
    [self addOneChildViewController:[[NavigationViewController alloc]initWithRootViewController:[[DataViewController alloc] init]]
                          WithTitle:@"Data".localized
                          imageName:@"tabbar_data_normal"
                  selectedImageName:@"tabbar_data_active"];
    
//    [self addOneChildViewController:[[CustomNavagationController alloc]initWithRootViewController:[[ServiceViewController alloc]init]]
//            WithTitle:@"Service".localized
//            imageName:@"tabbar_service_normal"
//    selectedImageName:@"tabbar_service_active"];
    
    [self addOneChildViewController:[[NavigationViewController alloc]initWithRootViewController:[[SetViewController alloc]init]]
                          WithTitle:@"Me".localized
                          imageName:@"tabbar_set_normal"
                  selectedImageName:@"tabbar_set_active"];
    
}

/**
 *  添加一个子控制器
 *
 *  @param viewController    控制器
 *  @param title             标题
 *  @param imageName         图片
 *  @param selectedImageName 选中图片
 */

- (void)addOneChildViewController:(UIViewController *)viewController WithTitle:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName{
    
    viewController.view.backgroundColor     = [UIColor whiteColor];
    viewController.tabBarItem.title         = title;
    viewController.tabBarItem.image         = [[UIImage imageNamed:imageName]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *image = [UIImage imageNamed:selectedImageName];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    viewController.tabBarItem.selectedImage = image;
    //    viewController.tabBarItem.selectedImage = [UIImage imageNamed:imageName];
    [self addChildViewController:viewController];
    
}

- (void)addOneNewChildViewController:(UIViewController *)viewController WithTitle:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName{
    
    viewController.view.backgroundColor     = [UIColor whiteColor];
    viewController.tabBarItem.title         = title;
    UIImage *image = [UIImage imageNamed:selectedImageName];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    viewController.tabBarItem.selectedImage = image;
    viewController.tabBarItem.image         = image;
    [viewController.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, 10)];
    [self addChildViewController:viewController];
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
