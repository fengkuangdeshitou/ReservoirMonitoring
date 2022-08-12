//
//  DeviceManager.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/8/12.
//

#import "DeviceManager.h"

@implementation DeviceManager

static DeviceManager * _manager = nil;

+ (instancetype)shareInstance{
    if (_manager == nil) {
        _manager = [[DeviceManager alloc] init];
    }
    return _manager;
}

@end
