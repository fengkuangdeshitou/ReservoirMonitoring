//
//  NetworkTableViewCell.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/5/9.
//

#import <UIKit/UIKit.h>
#import "DevideModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetworkTableViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UIImageView * bleIcon;
@property(nonatomic,weak)IBOutlet UIImageView * icon;
@property(nonatomic,weak)IBOutlet UILabel * titleLabel;
@property(nonatomic,weak)IBOutlet UILabel * address;
@property(nonatomic,weak)IBOutlet UILabel * status;
@property(nonatomic,weak)IBOutlet UIView * line;
@property(nonatomic,weak)IBOutlet NSLayoutConstraint * cententHeight;
@property(nonatomic,strong) DevideModel * model;

@end

NS_ASSUME_NONNULL_END
