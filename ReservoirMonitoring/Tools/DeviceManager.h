//
//  DeviceManager.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/8/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceManager : NSObject

+ (instancetype)shareInstance;

@property(nonatomic,assign) NSInteger deviceNumber;

@end

NS_ASSUME_NONNULL_END
