//
//  UWConfig.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/6/8.
//

#import "UWConfig.h"

static NSString *const UWUserLanguageKey = @"UWUserLanguageKey";
#define STANDARD_USER_DEFAULT  [NSUserDefaults standardUserDefaults]

@implementation UWConfig

+ (void)setUserLanguage:(NSString *)userLanguage
{
    //跟随手机系统
    if (!userLanguage.length) {
        [self resetSystemLanguage];
        return;
    }
    //用户自定义
    [STANDARD_USER_DEFAULT setValue:userLanguage forKey:UWUserLanguageKey];
    [STANDARD_USER_DEFAULT setValue:@[userLanguage] forKey:@"AppleLanguages"];
    [STANDARD_USER_DEFAULT synchronize];
}

+ (NSString *)userLanguage
{
    return [STANDARD_USER_DEFAULT valueForKey:UWUserLanguageKey];
}

/**
 重置系统语言
 */
+ (void)resetSystemLanguage
{
    [STANDARD_USER_DEFAULT removeObjectForKey:UWUserLanguageKey];
    [STANDARD_USER_DEFAULT setValue:nil forKey:@"AppleLanguages"];
    [STANDARD_USER_DEFAULT synchronize];
}

@end
