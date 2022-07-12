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
    [view makeToast:toast duration:2 position:@"center"];
}

+ (void)saveUserInfo:(NSDictionary *)userInfo{
    [[NSUserDefaults standardUserDefaults] setValue:userInfo forKey:K_USERINFO];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (int)getBleDataValue:(CGFloat)string{
    return string > 32768 ? (string - 65536) : string;
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

+ (NSMutableSet *)setForStartTime:(NSString *)startTime endTime:(NSString *)endTime{
    NSInteger startHour = [[startTime componentsSeparatedByString:@":"].firstObject integerValue];
    NSInteger startMinute = [[startTime componentsSeparatedByString:@":"].lastObject integerValue];
    NSInteger startTimeValue = startHour*24*60+startMinute*60;
    
    NSInteger endHour = [[endTime componentsSeparatedByString:@":"].firstObject integerValue];
    NSInteger endMinute = [[endTime componentsSeparatedByString:@":"].lastObject integerValue];
    NSInteger endTimeValue = endHour*24*60+endMinute*60;
    
    NSMutableSet * timeSet = [[NSMutableSet alloc] init];
    for (NSInteger i=startTimeValue; i<endTimeValue; i++) {
        [timeSet addObject:@(i)];
    }
    return timeSet;
}

+ (BOOL)isBetweenStartTime1:(NSString *)startTime1
                 startTime2:(NSString *)startTime2
                   endTime1:(NSString *)endTime1
                   endTime2:(NSString *)endTime2{
    NSMutableSet * startSet = [self setForStartTime:startTime1 endTime:startTime2];
    NSMutableSet * endSet = [self setForStartTime:endTime1 endTime:endTime2];
    [startSet intersectSet:endSet];
    NSLog(@"交集=%@",startSet);
    return startSet.count > 0;
}

+ (BOOL)hasRepeatedTimeForArray:(NSArray *)timeArray{
    BOOL result = false;
    if (timeArray.count <= 1) {
        return result;
    }else{
        for (int i = 0; i<timeArray.count; i++) {
            NSString * startTime = timeArray[i];
            NSString * hour = [startTime componentsSeparatedByString:@"_"][0];
            NSString * minute = [startTime componentsSeparatedByString:@"_"][1];
            for (int j=i+1; j<timeArray.count; j++) {
                NSString * endTime = timeArray[j];
                NSString * endTimeHour = [endTime componentsSeparatedByString:@"_"][0];
                NSString * endTimeMinute = [endTime componentsSeparatedByString:@"_"][1];
                result = [self isBetweenStartTime1:hour startTime2:minute endTime1:endTimeHour endTime2:endTimeMinute];
                if (result) {
                    return result;
                }
            }
        }
        return result;
    }
}

@end
