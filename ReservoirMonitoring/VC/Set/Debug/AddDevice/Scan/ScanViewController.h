//
//  ScanViewController.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/19.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScanViewController : BaseViewController

@property(nonatomic,copy) void(^scanCode)(NSString * code);

@end

NS_ASSUME_NONNULL_END
