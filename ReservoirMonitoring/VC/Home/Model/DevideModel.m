//
//  DevideModel.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/28.
//

#import "DevideModel.h"

@implementation DevideModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
        @"deviceId":@[@"id",@"devId"]
    };
}
@end
