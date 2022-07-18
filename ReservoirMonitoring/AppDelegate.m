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
    [UWConfig setUserLanguage:@"en"];
    [Bugly startWithAppId:@"0bf89be346"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:LOGIN_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadLoginController) name:LOG_OUT object:nil];
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = [UIColor colorWithHexString:@"#1E1E1E"];
    if ([NSUserDefaults.standardUserDefaults objectForKey:@"token"]) {
        [self loginSuccess];
    }else{
        [self loadLoginController];
    }
    
//    Byte byte[] = {97,98,99,49,50,51};
    Byte byte[] = {0x61,0x62,0x63,0x31,0x32,0x33};
    NSData * data = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"data=%@,string=%@",data,string);
    
    NSString *bcdstr = @"616263313233";
    int leng = (int)bcdstr.length/2;
    if (bcdstr.length%2 == 1) //判断奇偶数
    {
        leng +=1;
    }
    Byte bbte[leng];
    for (int i = 0; i<leng-1; i++)
    {
        bbte[i] = (int)strtoul([[bcdstr substringWithRange:NSMakeRange(i*2, 2)]UTF8String], 0, 16);
    }
    if (bcdstr.length%2 == 1)
    {
        bbte[leng-1] = (int)strtoul([[bcdstr substringWithRange:NSMakeRange((leng - 1)*2, 1)]UTF8String], 0, 16) *16;
    }else
    {
        bbte[leng-1] = (int)strtoul([[bcdstr substringWithRange:NSMakeRange((leng - 1)*2, 2)]UTF8String], 0, 16);
    }
    NSData *de = [[NSData alloc]initWithBytes:bbte length:leng];
    NSLog(@"%@",de);
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
