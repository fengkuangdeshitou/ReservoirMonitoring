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

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:LOGIN_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadLoginController) name:LOG_OUT object:nil];
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = [UIColor colorWithHexString:@"#1E1E1E"];
    [self loginSuccess];
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
