//
//  CountryCodeViewController.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/10/28.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CountryCodeViewController : BaseViewController

@property(nonatomic,copy) void(^selectCountryCode)(NSDictionary * item);

@end

NS_ASSUME_NONNULL_END
