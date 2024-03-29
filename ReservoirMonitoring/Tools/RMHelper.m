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
static NSString * K_USERTYPE = @"USERTYPE";
static NSString * K_TOURISTSMODEL = @"TOURISTSMODEL";


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
    [view makeToast:toast duration:1.5 position:@"center"];
}

+ (void)saveUserInfo:(NSDictionary *)userInfo{
    [[NSUserDefaults standardUserDefaults] setValue:userInfo forKey:K_USERINFO];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (int)getBleDataValue:(CGFloat)integer min:(NSInteger)min max:(NSInteger)max{
    if (integer >= min && integer <= max) {
        return 0;
    }else{
        return integer > 32768 ? (integer - 65536) : integer;
    }
}

+ (void)setUserType:(BOOL)isInstall{
    [NSUserDefaults.standardUserDefaults setBool:isInstall forKey:K_USERTYPE];
    [NSUserDefaults.standardUserDefaults synchronize];
}

+ (BOOL)getUserType{
    return [NSUserDefaults.standardUserDefaults boolForKey:K_USERTYPE];
}

+ (void)setLoadDataForBluetooth:(BOOL)isBluetooth{
    NSString * key = [NSString stringWithFormat:@"%@-%@",[NSUserDefaults.standardUserDefaults objectForKey:@"token"],[NSUserDefaults.standardUserDefaults objectForKey:CURRENR_DEVID]];
    [NSUserDefaults.standardUserDefaults setBool:isBluetooth forKey:key];
    [NSUserDefaults.standardUserDefaults synchronize];
}

+ (BOOL)getLoadDataForBluetooth{
    NSString * key = [NSString stringWithFormat:@"%@-%@",[NSUserDefaults.standardUserDefaults objectForKey:@"token"],[NSUserDefaults.standardUserDefaults objectForKey:CURRENR_DEVID]];
    return [NSUserDefaults.standardUserDefaults boolForKey:key];
}

+ (NSMutableSet *)setForStartTime:(NSString *)startTime endTime:(NSString *)endTime{
    NSInteger startHour = [[startTime componentsSeparatedByString:@":"].firstObject integerValue];
    NSInteger startMinute = [[startTime componentsSeparatedByString:@":"].lastObject integerValue];
    NSInteger startTimeValue = startHour*60*60+startMinute*60;
    
    NSInteger endHour = [[endTime componentsSeparatedByString:@":"].firstObject integerValue];
    NSInteger endMinute = [[endTime componentsSeparatedByString:@":"].lastObject integerValue];
    NSInteger endTimeValue = endHour*60*60+endMinute*60;
    
    if (endTimeValue <= startTimeValue) {
        return nil;
    }
    
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
    if (startSet && endSet) {
        [startSet intersectSet:endSet];
        return startSet.count > 0;
    }else{
        return YES;
    }
}

+ (BOOL)hasRepeatedTimeForArray:(NSArray *)timeArray{
    BOOL result = false;
    if (timeArray.count == 1) {
        NSString * startTime = timeArray[0];
        NSString * start = [startTime componentsSeparatedByString:@"_"][0];
        NSString * end = [startTime componentsSeparatedByString:@"_"][1];
        if (start.length > 0 && end.length > 0) {
            NSMutableSet * set = [self setForStartTime:start endTime:end];
            if (!set) {
                result = YES;
            }
        }
        return result;
    }else{
        for (int i = 0; i<timeArray.count-1; i++) {
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

+ (void)saveTouristsModel:(BOOL)model{
    [NSUserDefaults.standardUserDefaults setBool:model forKey:K_TOURISTSMODEL];
    [NSUserDefaults.standardUserDefaults synchronize];
}
/// 是否游客模式
+ (BOOL)isTouristsModel{
    return [NSUserDefaults.standardUserDefaults boolForKey:K_TOURISTSMODEL];
}

//  十进制转二进制
+ (NSString *)toBinarySystemWithDecimalSystem:(int)num length:(int)length{
    int remainder = 0;      //余数
    int divisor = 0;        //除数
    NSString * prepare = @"";
    while (true)
    {
        remainder = num%2;
        divisor = num/2;
        num = divisor;
        prepare = [prepare stringByAppendingFormat:@"%d",remainder];

        if (divisor == 0)
        {
            break;
        }
    }
    //倒序输出
    NSString * result = @"";
    for (int i = length -1; i >= 0; i --)
    {
        if (i <= prepare.length - 1) {
            result = [result stringByAppendingFormat:@"%@",
                      [prepare substringWithRange:NSMakeRange(i , 1)]];

        }else{
            result = [result stringByAppendingString:@"0"];

        }
    }
    return result;
}

@end
