//
//  RegisterViewController.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/12.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RegisterViewController : BaseViewController

@property(nonatomic,copy) void(^registerSuccess)(NSString * username, NSString * password);

@end

NS_ASSUME_NONNULL_END
