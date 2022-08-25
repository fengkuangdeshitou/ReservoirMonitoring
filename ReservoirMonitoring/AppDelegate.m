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
    NSArray * array = @[@"0",@"0",@"0",@"0"];
    NSDictionary * item = @{
        @"startTime":[NSString stringWithFormat:@"%02d:%02d",[array[0] intValue],[array[1] intValue]],
        @"endTime":[NSString stringWithFormat:@"%02d:%02d",[array[2] intValue],[array[3] intValue]],
    };
    NSArray * touArray = @[item,item,item];
    NSDictionary * data = @{@"offPeakTimeList":@[]};
    if (data[@"offPeakTimeList"]) {
        NSArray * offPeakTimeList = data[@"offPeakTimeList"];
        NSMutableArray * priceArray = [[NSMutableArray alloc] init];
        for (int i=0; i<offPeakTimeList.count; i++) {
            NSString * string = offPeakTimeList[i];
            if ([string containsString:@"_"]) {
                NSArray * timeArray = [string componentsSeparatedByString:@"_"];
                [priceArray addObject:timeArray.count>2?timeArray[2]:@""];
            }else{
                [priceArray addObject:@""];
            }
        }
        if (priceArray.count < touArray.count) {
            NSInteger number = touArray.count-priceArray.count;
            for (NSInteger i=0; i<number; i++) {
                [priceArray addObject:@""];
            }
        }
        NSMutableArray * array = [[NSMutableArray alloc] init];
        for (int i=0; i<touArray.count; i++) {
            NSMutableDictionary * item = [[NSMutableDictionary alloc] initWithDictionary:touArray[i]];
            [item setValue:priceArray[i] forKey:@"price"];
            [array addObject:item];
        }
        touArray = [[NSMutableArray alloc] initWithArray:array];
    }
    NSLog(@"tou=%@",touArray);
    
//    NSString * string = @"6403080000000000000000B2E7";
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
