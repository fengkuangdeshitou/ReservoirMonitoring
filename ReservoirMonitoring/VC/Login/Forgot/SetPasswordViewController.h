//
//  SetPasswordViewController.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/12.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SetPasswordViewController : BaseViewController

@property(nonatomic,strong)NSString * uuid;
@property(nonatomic,strong)NSString * userName;
@property(nonatomic,strong)NSString * code;

@end

NS_ASSUME_NONNULL_END
