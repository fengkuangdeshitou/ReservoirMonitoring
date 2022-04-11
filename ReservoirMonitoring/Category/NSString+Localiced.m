//
//  NSString+Localiced.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/11.
//

#import "NSString+Localiced.h"

@implementation NSString (Localiced)

- (NSString *)localized{
    return NSLocalizedString(self, nil);
}

@end
