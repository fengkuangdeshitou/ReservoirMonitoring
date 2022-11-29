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
#import "MessageDetailViewController.h"

@interface AppDelegate ()<MTPushRegisterDelegate,UNUserNotificationCenterDelegate>

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
                 apsForProduction:true
            advertisingIdentifier:nil];
    
    // 使用 UNUserNotificationCenter 来管理通知
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    //监听回调事件
    center.delegate = self;
    //iOS 10 使用以下方法注册，才能得到授权
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              // Enable or disable features based on authorization.
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
//    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
//    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kMTCNetworkDidReceiveMessageNotification object:nil];
    
    NSDictionary * userInfo = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo){
        if ([userInfo objectForKey:@"extras"]){
            NSDictionary * extras = [userInfo objectForKey:@"extras"];
            NSString * messageId = [extras objectForKey:@"notifyId"];
            [self pushToMessageDetails:messageId];
        }else if ([userInfo objectForKey:@"notifyId"]){
            NSString * messageId = [userInfo objectForKey:@"notifyId"];
            [self pushToMessageDetails:messageId];
        }
    }
    
    return YES;
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    NSDictionary * extras = [userInfo objectForKey:@"extras"];
    NSString * detail = [userInfo valueForKey:@"content"];
    UNTimeIntervalNotificationTrigger *timeTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:.5f repeats:NO];
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.body = detail;
    content.badge = @([UIApplication sharedApplication].applicationIconBadgeNumber + 1);
    content.sound = [UNNotificationSound defaultSound];
    content.userInfo = @{@"detail":detail,@"extras":extras};
    NSString *requestIdentifier = [NSString stringWithFormat:@"%lf", [[NSDate date] timeIntervalSince1970]];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:timeTrigger];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error)
        {
            NSLog(@"推送已经添加成功");
        }
    }];
}

- (void)loadLoginController{
    LoginViewController * login = [[LoginViewController alloc] init];
    NavigationViewController * nav = [[NavigationViewController alloc] initWithRootViewController:login];
    login.title = @"Login".localized;
    self.window.rootViewController = nav;
    if ([NSUserDefaults.standardUserDefaults objectForKey:@"token"]) {
        [self uploadPushRegistrationId:@""];
    }
}

- (void)loginSuccess{
    if (!RMHelper.isTouristsModel){
        [self getRegistrationId];
    }
    TabbarViewController * tabbar = [[TabbarViewController alloc] init];
    self.window.rootViewController = tabbar;
    [self.window makeKeyAndVisible];
}

- (void)getRegistrationId{
    [MTPushService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if (registrationID){
            [self uploadPushRegistrationId:registrationID];
        }
    }];
}

- (void)uploadPushRegistrationId:(NSString *)registrationId{
    [Request.shareInstance getUrl:SettingAlias params:@{@"registrationId":registrationId} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    /// Required - 注册 DeviceToken
    [MTPushService registerDeviceToken:deviceToken];
}

// iOS 12 Support
- (void)mtpNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification{
    if (notification) {
        //从通知界面直接进入应用
          
    }else{
        //从通知设置界面进入应用
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler{
    UNNotificationContent * content = response.notification.request.content;
    NSDictionary * userInfo = [content userInfo];
    if ([userInfo objectForKey:@"extras"]){
        NSDictionary * extras = [userInfo objectForKey:@"extras"];
        NSString * messageId = [extras objectForKey:@"notifyId"];
        [self pushToMessageDetails:messageId];
    }else if ([userInfo objectForKey:@"notifyId"]){
        NSString * messageId = [userInfo objectForKey:@"notifyId"];
        [self pushToMessageDetails:messageId];
    }
    completionHandler();
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    [application setApplicationIconBadgeNumber:0];
}

- (void)pushToMessageDetails:(NSString *)messageId{
    if ([RMHelper.getCurrentVC isKindOfClass:[MessageDetailViewController class]]){
        [NSNotificationCenter.defaultCenter postNotificationName:UPDATE_MESSAGEDETAIL_NOTIFICATION object:messageId];
    }else{
        MessageDetailViewController * detail = [[MessageDetailViewController alloc] initWithMessageId:messageId];
        detail.title = @"Message details";
        detail.hidesBottomBarWhenPushed = true;
        [RMHelper.getCurrentVC.navigationController pushViewController:detail animated:false];
    }
}

@end
