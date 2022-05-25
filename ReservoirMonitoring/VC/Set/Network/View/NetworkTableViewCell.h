//
//  NetworkTableViewCell.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/5/9.
//

#import <UIKit/UIKit.h>
#import "PeripheralModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetworkTableViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UIImageView * bleIcon;
@property(nonatomic,strong) PeripheralModel * model;

@end

NS_ASSUME_NONNULL_END