//
//  HomeTableViewCell.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/13.
//

#import <UIKit/UIKit.h>
#import "DevideModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeTableViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UIButton * changeDeviceButton;
@property(nonatomic,strong) DevideModel * model;

@end

NS_ASSUME_NONNULL_END
