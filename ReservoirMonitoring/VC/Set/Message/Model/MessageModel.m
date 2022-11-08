//
//  MessageModel.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/11/8.
//

#import "MessageModel.h"

@implementation MessageModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
        @"Id":@"id"
    };
}

@end
