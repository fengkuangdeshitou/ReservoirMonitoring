//
//  UWConfig.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/6/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 设置类
 */
@interface UWConfig : NSObject
/**
 用户自定义使用的语言，当传nil时，等同于resetSystemLanguage
 */
@property (class, nonatomic, strong, nullable) NSString *userLanguage;
/**
 重置系统语言
 */
+ (void)resetSystemLanguage;

@end

NS_ASSUME_NONNULL_END
