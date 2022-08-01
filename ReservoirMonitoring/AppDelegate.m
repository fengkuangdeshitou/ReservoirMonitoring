//
//  AppDelegate.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/11.
//

#import "AppDelegate.h"
#import "TabbarViewController.h"
#import "NavigationViewController.h"
#import "LoginViewController.h"
#import "UWConfig.h"
#import <Bugly/Bugly.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [UWConfig setUserLanguage:@"zh-Hans"];
    sleep(2);
    [UWConfig setUserLanguage:@"en"];
    [Bugly startWithAppId:@"dde48f2e31"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:LOGIN_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadLoginController) name:LOG_OUT object:nil];
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = [UIColor colorWithHexString:@"#1E1E1E"];
    if ([NSUserDefaults.standardUserDefaults objectForKey:@"token"]) {
        [self loginSuccess];
    }else{
        [self loadLoginController];
    }
//    NSString * string = @"640306000010000000B2E7";
    
//    BOOL result = [RMHelper hasRepeatedTimeForArray:@[@"00:01_00:02",@"00:02_00:03",@"00:01_00:03"]];
//    NSLog(@"时间交集=%@",result?@"有交集":@"无交集");
    return YES;
}

- (void)loadLoginController{
    LoginViewController * login = [[LoginViewController alloc] init];
    NavigationViewController * nav = [[NavigationViewController alloc] initWithRootViewController:login];
    login.title = @"Login".localized;
    self.window.rootViewController = nav;
}

- (void)loginSuccess{
    TabbarViewController * tabbar = [[TabbarViewController alloc] init];
    self.window.rootViewController = tabbar;
    [self.window makeKeyAndVisible];
}

@end
