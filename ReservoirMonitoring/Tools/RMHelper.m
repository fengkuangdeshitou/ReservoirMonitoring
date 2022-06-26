//
//  RMHelper.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/11.
//

#import "RMHelper.h"
#import "Toast+UIView.h"

@implementation RMHelper

static NSString * K_USERINFO = @"PFUserInfo";
static NSString * K_DATASOURCE = @"DATASOURCE";
static NSString * K_USERTYPE = @"USERTYPE";


+ (UIViewController *)jsd_getRootViewController{

    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    NSAssert(window, @"The window is empty");
    return window.rootViewController;
}

+ (UIViewController *)getCurrentVC
{
    UIViewController* currentViewController = [self jsd_getRootViewController];

    BOOL runLoopFind = YES;
    while (runLoopFind) {
        if (currentViewController.presentedViewController) {
            currentViewController = currentViewController.presentedViewController;
        } else {
            if ([currentViewController isKindOfClass:[UINavigationController class]]) {
                currentViewController = ((UINavigationController *)currentViewController).visibleViewController;
            } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
                currentViewController = ((UITabBarController* )currentViewController).selectedViewController;
            } else {
                break;
            }
        }
    }
    return currentViewController;
}

+ (void)showToast:(NSString *)toast toView:(UIView *)view{
    [view makeToast:toast duration:2 position:@"bottom"];
}

+ (void)saveUserInfo:(NSDictionary *)userInfo{
    [[NSUserDefaults standardUserDefaults] setValue:userInfo forKey:K_USERINFO];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (int)getBleDataValue:(NSString *)string{
    int data = string.intValue;
    return data > 32768 ? (data - 65536) : data;
}

+ (void)setUserType:(BOOL)isInstall{
    [NSUserDefaults.standardUserDefaults setBool:isInstall forKey:K_USERTYPE];
}

+ (BOOL)getUserType{
    return [NSUserDefaults.standardUserDefaults boolForKey:K_USERTYPE];
}

+ (void)setLoadDataForBluetooth:(BOOL)isBluetooth{
    [NSUserDefaults.standardUserDefaults setBool:isBluetooth forKey:K_DATASOURCE];
}

+ (BOOL)getLoadDataForBluetooth{
    return [NSUserDefaults.standardUserDefaults boolForKey:K_DATASOURCE];
}

@end
