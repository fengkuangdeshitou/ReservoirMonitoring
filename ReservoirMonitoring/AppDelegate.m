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
#import <MTPushService.h>
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()<MTPushRegisterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [UWConfig setUserLanguage:@"zh-Hans"];
    sleep(2);
    
    MTPushRegisterEntity * entity = [[MTPushRegisterEntity alloc] init];
    entity.types = MTPushAuthorizationOptionAlert|MTPushAuthorizationOptionBadge|MTPushAuthorizationOptionSound|MTPushAuthorizationOptionProvidesAppNotificationSettings;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
      // 可以添加自定义 categories
      // NSSet<UNNotificationCategory *> *categories for iOS10 or later
      // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [MTPushService registerForRemoteNotificationConfig:entity delegate:self];
    [MTPushService setupWithOption:launchOptions
                           appKey:@"6858da78bce469a1492408ba"
                          channel:@"App Store"
                 apsForProduction:false
            advertisingIdentifier:nil];
    [MTPushService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
            
    }];
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

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    /// Required - 注册 DeviceToken
    [MTPushService registerDeviceToken:deviceToken];
}

// iOS 12 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification{
    if (notification && [notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //从通知界面直接进入应用
    }else{
        //从通知设置界面进入应用
    }
}

@end
