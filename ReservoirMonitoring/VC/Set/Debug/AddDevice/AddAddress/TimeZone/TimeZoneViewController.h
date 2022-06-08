//
//  TimeZoneViewController.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/6/8.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TimeZoneViewController : BaseViewController

@property(nonatomic,strong) NSString * countryId;
@property(nonatomic,copy) void(^selectTimeZone)(NSDictionary * item);

@end

NS_ASSUME_NONNULL_END
