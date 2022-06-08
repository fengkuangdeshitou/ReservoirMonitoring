//
//  DeviceSwitchTableViewCell.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import <UIKit/UIKit.h>
#import "DevideModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceSwitchTableViewCell : UITableViewCell

@property(nonatomic,strong) DevideModel * model;
@property(nonatomic,weak)IBOutlet UIButton * switchDeviceBtn;

@end

NS_ASSUME_NONNULL_END
